import { createHash } from 'node:crypto';
import { cp, lstat, mkdir, mkdtemp, readFile, readdir, realpath, rename, rm, writeFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const hash = data => createHash('sha256').update(data).digest('hex');
const namePattern = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const fail = code => { throw new Error(code); };

async function files(root, prefix = '', hashes = true) {
  if (!(await lstat(path.join(root, prefix))).isDirectory()) fail('bundle_symlink');
  const result = {};
  for (const entry of (await readdir(path.join(root, prefix))).sort()) {
    const relative = path.posix.join(prefix, entry);
    const stat = await lstat(path.join(root, relative));
    if (stat.isSymbolicLink()) fail('bundle_symlink');
    if (stat.isDirectory()) Object.assign(result, await files(root, relative, hashes));
    else if (stat.isFile()) {
      if (hashes) result[relative] = hash(await readFile(path.join(root, relative)));
    }
    else fail('bundle_special_file');
  }
  return result;
}

export async function buildBundle(source, destination, revision) {
  if (!/^[a-f0-9]{40}$/.test(revision)) fail('invalid_revision');
  source = await realpath(source);
  destination = path.resolve(destination);
  if ([path.parse(destination).root, os.homedir(), process.cwd()].includes(destination) ||
      source === destination || source.startsWith(destination + path.sep) ||
      destination.startsWith(source + path.sep)) fail('invalid_destination');
  await safeDirectory(path.dirname(destination));
  if (await exists(destination)) {
    await safeDirectory(destination);
    const entries = await readdir(destination);
    if (entries.some(name => !['manifest.json', 'skills'].includes(name)) ||
        (entries.length && !entries.includes('manifest.json'))) fail('invalid_destination');
    await files(destination, '', false);
  }
  const sourceSkills = path.join(source, 'skills');
  const names = [];
  for (const entry of (await readdir(sourceSkills)).sort()) {
    if (!namePattern.test(entry)) fail('invalid_skill_name');
    const directory = path.join(sourceSkills, entry);
    if (!(await lstat(directory)).isDirectory()) fail('invalid_skill_directory');
    const content = await readFile(path.join(directory, 'SKILL.md'), 'utf8');
    const frontmatter = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
    if (!frontmatter || !/^name:[ \t]*\S[^\r\n]*$/m.test(frontmatter[1]) || !/^description:[ \t]*\S[^\r\n]*$/m.test(frontmatter[1])) fail('invalid_skill_metadata');
    await files(directory, '', false);
    names.push(entry);
  }
  if (!names.length) fail('empty_bundle');
  const staging = await mkdtemp(path.join(path.dirname(destination), '.skill-build-'));
  try {
    await mkdir(path.join(staging, 'skills'));
    for (const name of names) await cp(path.join(sourceSkills, name), path.join(staging, 'skills', name), { recursive: true });
    const manifest = { schema: 1, revision, skills: names, files: await files(path.join(staging, 'skills')) };
    await writeFile(path.join(staging, 'manifest.json'), JSON.stringify(manifest));
    await verifyBundle(staging);
    await rm(destination, { recursive: true, force: true });
    await rename(staging, destination);
    return (await verifyBundle(destination)).digest;
  } finally {
    await rm(staging, { recursive: true, force: true });
  }
}

export async function verifyBundle(bundle) {
  const raw = await readFile(path.join(bundle, 'manifest.json'), 'utf8');
  const manifest = JSON.parse(raw);
  if (manifest?.schema !== 1 || !/^[a-f0-9]{40}$/.test(manifest.revision) || !Array.isArray(manifest.skills) || !manifest.skills.length || !manifest.skills.every(name => typeof name === 'string' && namePattern.test(name))) fail('invalid_manifest');
  const actual = await files(path.join(bundle, 'skills'));
  if (JSON.stringify(actual) !== JSON.stringify(manifest.files)) fail('bundle_integrity_failed');
  if (manifest.skills.some(name => !actual[`${name}/SKILL.md`])) fail('missing_skill');
  if (new Set(manifest.skills).size !== manifest.skills.length || Object.keys(actual).some(file => !manifest.skills.includes(file.split('/')[0]))) fail('invalid_manifest');
  if (JSON.stringify((await readdir(path.join(bundle, 'skills'))).sort()) !== JSON.stringify([...manifest.skills].sort())) fail('invalid_manifest');
  return { ...manifest, digest: hash(raw) };
}

async function safeDirectory(directory, create = false) {
  const parent = path.dirname(directory);
  if (parent !== directory) await safeDirectory(parent);
  if (create) await mkdir(directory).catch(error => { if (error.code !== 'EEXIST') throw error; });
  if (!(await lstat(directory)).isDirectory()) fail('workspace_symlink');
}

const exists = async entry => {
  try { await lstat(entry); return true; }
  catch (error) { if (error.code === 'ENOENT') return false; throw error; }
};
const cleanup = directory => rm(directory, { recursive: true, force: true }).catch(() => {});

// Unlike image-owned bundles, repositories may alias Skills (e.g. to .claude).
// Never read file bodies or dereference links while copying or removing a tree.
// Recovery scans types only: relative links are meaningful at the live location,
// not inside a transaction. Validate their destinations after restoring backup.
async function workspaceFiles(root, workspace, ancestors = new Set()) {
  if (!(await lstat(root)).isDirectory()) fail('workspace_symlink');
  if (ancestors.has(root)) fail('workspace_symlink_cycle');
  const parents = new Set([...ancestors, root]);
  for (const entry of await readdir(root)) {
    const file = path.join(root, entry);
    const stat = await lstat(file);
    if (stat.isSymbolicLink()) {
      if (!workspace) continue;
      let resolved;
      try { resolved = await realpath(file); }
      catch { fail('workspace_symlink_invalid'); }
      const relative = path.relative(workspace, resolved);
      if (relative === '..' || relative.startsWith(`..${path.sep}`) || path.isAbsolute(relative)) fail('workspace_symlink_outside');
      const destination = await lstat(resolved);
      if (destination.isDirectory()) await workspaceFiles(resolved, workspace, parents);
      else if (!destination.isFile()) fail('workspace_special_file');
    } else if (stat.isDirectory()) await workspaceFiles(file, workspace, parents);
    else if (!stat.isFile()) fail('workspace_special_file');
  }
}

// The caller holds flock. Backup presence is the recovery journal:
// absent target + backup => restore old; present target => publication completed.
async function recoverTransactions(state, target) {
  const transactions = (await readdir(state)).filter(name => name.startsWith('txn-'));
  if (transactions.length > 1) fail('recovery_ambiguous');
  for (const name of transactions) {
    const transaction = path.join(state, name);
    await workspaceFiles(transaction);
    const backup = path.join(transaction, 'backup');
    if (!(await exists(target))) {
      if (!(await exists(backup))) fail('recovery_ambiguous');
      await safeDirectory(backup);
      await rename(backup, target);
    }
    await cleanup(transaction);
    if (await exists(transaction)) fail('recovery_cleanup_failed');
  }
}

async function recoverLegacy(agentRoot, target) {
  const entries = await readdir(agentRoot);
  const backups = entries.filter(name => /^skills-backup-\d+$/.test(name));
  const stages = entries.filter(name => /^skills-stage-\d+$/.test(name));
  if (!backups.length && !stages.length) return;
  if (backups.length !== 1 || await exists(target)) fail('recovery_ambiguous');
  const backup = path.join(agentRoot, backups[0]);
  await workspaceFiles(backup);
  await rename(backup, target);
  // A stage may be incomplete. Never promote it over the previous user's tree.
  for (const name of stages) {
    const stage = path.join(agentRoot, name);
    await workspaceFiles(stage);
    await cleanup(stage);
  }
}

export async function prepareBundle(bundle, workspace) {
  const manifest = await verifyBundle(bundle);
  await safeDirectory(workspace);
  const agentRoot = path.join(workspace, '.agents');
  await safeDirectory(agentRoot, true);
  const target = path.join(agentRoot, 'skills');
  const state = path.join(workspace, '.sealai-skill-transactions');
  await safeDirectory(state, true);
  await recoverTransactions(state, target);
  await recoverLegacy(agentRoot, target);
  await safeDirectory(target, true);
  await workspaceFiles(target, workspace);
  const transaction = await mkdtemp(path.join(state, 'txn-'));
  const stage = path.join(transaction, 'stage');
  const backup = path.join(transaction, 'backup');
  try {
    await cp(target, stage, { recursive: true, dereference: false, verbatimSymlinks: true });
    for (const name of manifest.skills) {
      await rm(path.join(stage, name), { recursive: true, force: true });
      await cp(path.join(bundle, 'skills', name), path.join(stage, name), { recursive: true });
    }
    await rename(target, backup);
    await rename(stage, target);
  } catch (error) {
    // If restoration throws, retain the transaction for the next invocation.
    if (await exists(backup) && !(await exists(target))) await rename(backup, target);
    await cleanup(transaction);
    throw error;
  }
  await cleanup(transaction); // Publication succeeded; cleanup is best-effort.
  return { schema: 1, status: 'ready', revision: manifest.revision, digest: manifest.digest, skillCount: manifest.skills.length };
}

export function validateReady(raw) {
  let value;
  try { value = JSON.parse(raw); } catch { fail('invalid_ready'); }
  if (value?.schema !== 1 || value.status !== 'ready' ||
      !/^[a-f0-9]{40}$/.test(value.revision) || !/^[a-f0-9]{64}$/.test(value.digest) ||
      !Number.isSafeInteger(value.skillCount) || value.skillCount < 1) fail('invalid_ready');
  return { schema: 1, status: 'ready', revision: value.revision, digest: value.digest, skillCount: value.skillCount };
}

if (process.argv[1] && await realpath(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [operation, ...args] = process.argv.slice(2);
  try {
    let result;
    if (operation === 'build') result = await buildBundle(...args);
    else if (operation === 'verify') result = await verifyBundle(...args);
    else if (operation === 'prepare' || operation === 'prepare-chat') {
      if (operation === 'prepare-chat') await safeDirectory(args[1], true);
      result = await prepareBundle(...args);
    } else if (operation === 'validate-ready') {
      let raw = '';
      for await (const chunk of process.stdin) raw += chunk;
      result = validateReady(raw);
    } else fail('invalid_operation');
    console.log(JSON.stringify(result));
  } catch {
    console.error(JSON.stringify({ schema: 1, status: 'failed', reason: 'skill_bundle_unavailable' }));
    process.exitCode = 1;
  }
}
