import { createHash } from 'node:crypto';
import { cp, lstat, mkdir, readFile, readdir, rename, rm, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const hash = data => createHash('sha256').update(data).digest('hex');
const namePattern = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const fail = code => { throw new Error(code); };

async function files(root, prefix = '') {
  if (!(await lstat(path.join(root, prefix))).isDirectory()) fail('bundle_symlink');
  const result = {};
  for (const entry of (await readdir(path.join(root, prefix))).sort()) {
    const relative = path.posix.join(prefix, entry);
    const stat = await lstat(path.join(root, relative));
    if (stat.isSymbolicLink()) fail('bundle_symlink');
    if (stat.isDirectory()) Object.assign(result, await files(root, relative));
    else if (stat.isFile()) result[relative] = hash(await readFile(path.join(root, relative)));
    else fail('bundle_special_file');
  }
  return result;
}

export async function buildBundle(source, destination, revision) {
  if (!/^[a-f0-9]{40}$/.test(revision)) fail('invalid_revision');
  const sourceSkills = path.join(source, 'skills');
  const names = [];
  for (const entry of (await readdir(sourceSkills)).sort()) {
    if (!namePattern.test(entry)) fail('invalid_skill_name');
    const directory = path.join(sourceSkills, entry);
    if (!(await lstat(directory)).isDirectory()) fail('invalid_skill_directory');
    const content = await readFile(path.join(directory, 'SKILL.md'), 'utf8');
    const frontmatter = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
    if (!frontmatter || !/^name:[ \t]*\S[^\r\n]*$/m.test(frontmatter[1]) || !/^description:[ \t]*\S[^\r\n]*$/m.test(frontmatter[1])) fail('invalid_skill_metadata');
    await files(directory);
    names.push(entry);
  }
  if (!names.includes('sealos-deploy')) fail('missing_deploy_skill');
  await mkdir(path.join(destination, 'skills'), { recursive: true });
  for (const name of names) await cp(path.join(sourceSkills, name), path.join(destination, 'skills', name), { recursive: true });
  const manifest = { schema: 1, revision, skills: names, files: await files(path.join(destination, 'skills')) };
  await writeFile(path.join(destination, 'manifest.json'), JSON.stringify(manifest));
  return hash(JSON.stringify(manifest));
}

export async function verifyBundle(bundle) {
  const raw = await readFile(path.join(bundle, 'manifest.json'), 'utf8');
  const manifest = JSON.parse(raw);
  if (manifest.schema !== 1 || !/^[a-f0-9]{40}$/.test(manifest.revision) || !Array.isArray(manifest.skills) || !manifest.skills.includes('sealos-deploy') || !manifest.skills.every(name => typeof name === 'string' && namePattern.test(name))) fail('invalid_manifest');
  const actual = await files(path.join(bundle, 'skills'));
  if (JSON.stringify(actual) !== JSON.stringify(manifest.files)) fail('bundle_integrity_failed');
  if (manifest.skills.some(name => !actual[`${name}/SKILL.md`])) fail('missing_skill');
  if (new Set(manifest.skills).size !== manifest.skills.length || Object.keys(actual).some(file => !manifest.skills.includes(file.split('/')[0]))) fail('invalid_manifest');
  return { ...manifest, digest: hash(raw) };
}

async function safeDirectory(directory) {
  const parent = path.dirname(directory);
  if (parent !== directory) await safeDirectory(parent);
  await mkdir(directory).catch(error => { if (error.code !== 'EEXIST') throw error; });
  if (!(await lstat(directory)).isDirectory()) fail('workspace_symlink');
}

// Caller holds flock for the whole operation. Stage before replacing; preserve
// unrelated project skills and reject symlinks before any copy or rename.
export async function prepareBundle(bundle, workspace) {
  const manifest = await verifyBundle(bundle);
  await safeDirectory(workspace);
  const agentRoot = path.join(workspace, '.agents');
  await safeDirectory(agentRoot);
  const target = path.join(agentRoot, 'skills');
  await safeDirectory(target);
  await files(target);
  const stage = path.join(agentRoot, `skills-stage-${process.pid}`);
  const backup = path.join(agentRoot, `skills-backup-${process.pid}`);
  // Exclusive mkdir avoids following paths placed by a repository.
  await mkdir(stage);
  let backedUp = false;
  try {
    await cp(target, stage, { recursive: true });
    for (const name of manifest.skills) {
      await rm(path.join(stage, name), { recursive: true, force: true });
      await cp(path.join(bundle, 'skills', name), path.join(stage, name), { recursive: true });
    }
    // Reserve backup name; refuse any existing entry.
    await mkdir(backup);
    await rename(target, backup);
    backedUp = true;
    await rename(stage, target);
    backedUp = false;
    await rm(backup, { recursive: true, force: true });
  } catch (error) {
    if (backedUp) await rename(backup, target);
    throw error;
  } finally {
    await rm(stage, { recursive: true, force: true });
  }
  return { schema: 1, status: 'ready', revision: manifest.revision, digest: manifest.digest, skillCount: manifest.skills.length };
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [operation, ...args] = process.argv.slice(2);
  try {
    const result = operation === 'build' ? await buildBundle(...args)
      : operation === 'verify' ? await verifyBundle(...args)
      : operation === 'prepare' ? await prepareBundle(...args)
      : fail('invalid_operation');
    console.log(JSON.stringify(result));
  } catch {
    // Never forward repository paths, file content or raw exceptions.
    console.error(JSON.stringify({ schema: 1, status: 'failed', reason: 'skill_bundle_unavailable' }));
    process.exitCode = 1;
  }
}
