import assert from 'node:assert/strict';
import { lstat, mkdtemp, mkdir, readFile, readlink, realpath, rename, rm, symlink, writeFile } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { buildBundle, prepareBundle, validateReady, verifyBundle } from './skill-bundle.mjs';

const revision = 'b'.repeat(40);
async function fixture(t, names = ['sealos-deploy']) {
  const root = await mkdtemp(path.join(await realpath(os.tmpdir()), 'skills-regression-'));
  t.after(() => rm(root, { recursive: true, force: true }));
  const source = path.join(root, 'source');
  const bundle = path.join(root, 'bundle');
  const workspace = path.join(root, 'workspace');
  await mkdir(workspace);
  for (const name of names) {
    await mkdir(path.join(source, 'skills', name), { recursive: true });
    await writeFile(path.join(source, 'skills', name, 'SKILL.md'), `---\nname: ${name}\ndescription: >\n  A Skill.\n---\n# Instructions`);
  }
  await buildBundle(source, bundle, revision);
  return { root, source, bundle, workspace };
}

async function repositoryAlias(f, name = 'custom') {
  const original = path.join(f.workspace, '.claude/skills', name);
  const target = path.join(f.workspace, '.agents/skills');
  await mkdir(original, { recursive: true });
  await mkdir(target, { recursive: true });
  await writeFile(path.join(original, 'SKILL.md'), 'repository skill');
  const link = path.join(target, name);
  const text = `../../.claude/skills/${name}`;
  await symlink(text, link);
  return { original, link, text };
}

test('Actual-style repository aliases retain their text and target across repeated preparation', async t => {
  const f = await fixture(t);
  const alias = await repositoryAlias(f);
  // File aliases inside a referenced directory must also remain valid.
  await symlink('SKILL.md', path.join(alias.original, 'instructions.md'));
  for (let attempt = 0; attempt < 2; attempt++) {
    assert.equal((await prepareBundle(f.bundle, f.workspace)).status, 'ready');
    assert.equal(await readlink(alias.link), alias.text);
    assert.equal(await realpath(alias.link), alias.original);
    assert.equal(await readFile(path.join(alias.link, 'instructions.md'), 'utf8'), 'repository skill');
    assert.match(await readFile(path.join(f.workspace, '.agents/skills/sealos-deploy/SKILL.md'), 'utf8'), /# Instructions/);
  }
});

test('replacing a bundled Skill alias never overwrites the repository destination', async t => {
  const f = await fixture(t);
  const alias = await repositoryAlias(f, 'sealos-deploy');
  await prepareBundle(f.bundle, f.workspace);
  assert.equal((await lstat(alias.link)).isDirectory(), true);
  assert.match(await readFile(path.join(alias.link, 'SKILL.md'), 'utf8'), /# Instructions/);
  assert.equal(await readFile(path.join(alias.original, 'SKILL.md'), 'utf8'), 'repository skill');
});

for (const kind of ['external', 'indirect-external', 'dangling', 'link-cycle', 'directory-cycle']) {
  test(`unsafe ${kind} alias fails without changing repository files`, async t => {
    const f = await fixture(t);
    const alias = await repositoryAlias(f);
    const bad = path.join(alias.original, 'bad');
    if (kind === 'external') await symlink(f.source, bad);
    if (kind === 'indirect-external') {
      await symlink(f.source, path.join(f.workspace, 'redirect'));
      await symlink('../../../redirect', bad);
    }
    if (kind === 'dangling') await symlink('missing', bad);
    if (kind === 'link-cycle') await symlink('bad', bad);
    if (kind === 'directory-cycle') await symlink('.', bad);
    await assert.rejects(prepareBundle(f.bundle, f.workspace), /workspace_symlink/);
    assert.equal(await readlink(alias.link), alias.text);
    assert.equal(await readFile(path.join(alias.original, 'SKILL.md'), 'utf8'), 'repository skill');
    await assert.rejects(lstat(path.join(f.workspace, '.agents/skills/sealos-deploy')), { code: 'ENOENT' });
  });
}

test('a symlink cannot replace the transaction backup root', async t => {
  const f = await fixture(t);
  const transaction = path.join(f.workspace, '.sealai-skill-transactions/txn-interrupted');
  await mkdir(transaction, { recursive: true });
  await symlink(f.source, path.join(transaction, 'backup'));
  await assert.rejects(prepareBundle(f.bundle, f.workspace), /workspace_symlink/);
  assert.equal(await readlink(path.join(transaction, 'backup')), f.source);
  await assert.rejects(lstat(path.join(f.workspace, '.agents/skills')), { code: 'ENOENT' });
});

test('restored aliases are validated at their live location before a new replacement', async t => {
  const f = await fixture(t);
  const alias = await repositoryAlias(f);
  const target = path.join(f.workspace, '.agents/skills');
  const transaction = path.join(f.workspace, '.sealai-skill-transactions/txn-interrupted');
  await mkdir(transaction, { recursive: true });
  await rename(target, path.join(transaction, 'backup'));
  await symlink(f.source, path.join(alias.original, 'escaped'));
  await assert.rejects(prepareBundle(f.bundle, f.workspace), /workspace_symlink_outside/);
  assert.equal(await readlink(alias.link), alias.text);
  assert.equal(await readFile(path.join(alias.original, 'SKILL.md'), 'utf8'), 'repository skill');
  await assert.rejects(lstat(path.join(target, 'sealos-deploy')), { code: 'ENOENT' });
});

test('all source Skills are bundled without a name or count allowlist', async t => {
  const f = await fixture(t, ['new-tool', 'another-tool']);
  assert.deepEqual((await verifyBundle(f.bundle)).skills, ['another-tool', 'new-tool']);
  assert.equal((await prepareBundle(f.bundle, f.workspace)).skillCount, 2);
});

test('dirty build output cannot produce a successful but invalid bundle', async t => {
  const f = await fixture(t);
  await mkdir(path.join(f.bundle, 'skills/stale'));
  await writeFile(path.join(f.bundle, 'skills/stale/SKILL.md'), 'stale');
  await buildBundle(f.source, f.bundle, revision);
  assert.deepEqual((await verifyBundle(f.bundle)).skills, ['sealos-deploy']);
});

test('retry restores unrelated Skills from a legacy interrupted replacement', async t => {
  const f = await fixture(t);
  await prepareBundle(f.bundle, f.workspace);
  const target = path.join(f.workspace, '.agents/skills');
  await mkdir(path.join(target, 'custom'));
  await writeFile(path.join(target, 'custom/keep'), 'user content');
  const alias = await repositoryAlias(f, 'repo-alias');
  await rename(target, path.join(f.workspace, '.agents/skills-backup-99999'));
  await mkdir(path.join(f.workspace, '.agents/skills-stage-99999'));
  assert.equal((await prepareBundle(f.bundle, f.workspace)).status, 'ready');
  assert.equal(await readFile(path.join(target, 'custom/keep'), 'utf8'), 'user content');
  assert.equal(await readlink(alias.link), alias.text);
  assert.equal(await realpath(alias.link), alias.original);
});

test('deployment preparation requires an existing workspace', async t => {
  const f = await fixture(t);
  await assert.rejects(prepareBundle(f.bundle, path.join(f.root, 'not-cloned')));
});

test('CLI invocation through a symlink must execute, not exit with empty success', async t => {
  const f = await fixture(t);
  const alias = path.join(f.root, 'bundle-cli.mjs');
  await symlink(new URL('./skill-bundle.mjs', import.meta.url).pathname, alias);
  const result = spawnSync(process.execPath, [alias, 'verify', f.bundle], { encoding: 'utf8' });
  assert.equal(result.status, 0);
  assert.equal(JSON.parse(result.stdout).revision, revision);
});

for (const checkpoint of ['backup', 'published']) {
  test(`SIGKILL after ${checkpoint} preserves custom Skills on retry`, async t => {
    const f = await fixture(t);
    await prepareBundle(f.bundle, f.workspace);
    const target = path.join(f.workspace, '.agents/skills');
    await mkdir(path.join(target, 'custom'));
    await writeFile(path.join(target, 'custom/keep'), 'user content');
    const alias = await repositoryAlias(f, 'repo-alias');
    // This link would be dangling if resolved at the backup/stage location.
    await symlink('../custom/keep', path.join(target, 'custom/keep-alias'));
    const child = spawnSync(process.execPath, ['--input-type=module', '-e', `
      import fs from 'node:fs';
      import { syncBuiltinESMExports } from 'node:module';
      const rename = fs.promises.rename;
      fs.promises.rename = async (from, to) => {
        await rename(from, to);
        if (${JSON.stringify(checkpoint)} === 'backup' ? to.endsWith('/backup') : from.endsWith('/stage')) process.kill(process.pid, 'SIGKILL');
      };
      syncBuiltinESMExports();
      const { prepareBundle } = await import(${JSON.stringify(new URL('./skill-bundle.mjs', import.meta.url).href)});
      await prepareBundle(${JSON.stringify(f.bundle)}, ${JSON.stringify(f.workspace)});
    `], { encoding: 'utf8' });
    assert.equal(child.signal, 'SIGKILL', child.stderr);
    assert.equal((await prepareBundle(f.bundle, f.workspace)).status, 'ready');
    assert.equal(await readFile(path.join(target, 'custom/keep'), 'utf8'), 'user content');
    assert.equal(await readlink(alias.link), alias.text);
    assert.equal(await realpath(alias.link), alias.original);
    assert.equal(await readFile(path.join(target, 'custom/keep-alias'), 'utf8'), 'user content');
  });
}

test('Chat explicitly creates its workspace without weakening the deployment precondition', async t => {
  const f = await fixture(t);
  const workspace = path.join(f.root, 'chat');
  const child = spawnSync(process.execPath, [new URL('./skill-bundle.mjs', import.meta.url).pathname, 'prepare-chat', f.bundle, workspace], { encoding: 'utf8' });
  assert.equal(child.status, 0, child.stderr);
  assert.equal(validateReady(child.stdout).status, 'ready');
});

test('success output must match the ready contract', () => {
  for (const raw of ['', '{}', 'null', '{"schema":1,"status":"ready"}', '{"status":"failed"}']) {
    assert.throws(() => validateReady(raw), /invalid_ready/);
  }
  const ready = { schema: 1, status: 'ready', revision, digest: 'c'.repeat(64), skillCount: 4 };
  assert.deepEqual(validateReady(JSON.stringify({ ...ready, untrusted: 'discard' })), ready);
});

test('preparation does not read or hash workspace file bodies', async t => {
  const f = await fixture(t);
  await prepareBundle(f.bundle, f.workspace);
  const child = spawnSync(process.execPath, ['--input-type=module', '-e', `
    import fs from 'node:fs';
    import { syncBuiltinESMExports } from 'node:module';
    const readFile = fs.promises.readFile;
    fs.promises.readFile = async (file, options) => {
      if (String(file).startsWith(${JSON.stringify(f.workspace)})) throw new Error('workspace content read');
      return readFile(file, options);
    };
    syncBuiltinESMExports();
    const { prepareBundle } = await import(${JSON.stringify(new URL('./skill-bundle.mjs', import.meta.url).href)});
    console.log(JSON.stringify(await prepareBundle(${JSON.stringify(f.bundle)}, ${JSON.stringify(f.workspace)})));
  `], { encoding: 'utf8' });
  assert.equal(child.status, 0, child.stderr);
  assert.equal(validateReady(child.stdout).status, 'ready');
});

test('ambiguous legacy backups fail closed without hiding preserved content', async t => {
  const f = await fixture(t);
  const agent = path.join(f.workspace, '.agents');
  for (const id of ['1', '2']) {
    await mkdir(path.join(agent, 'skills-backup-' + id), { recursive: true });
    await writeFile(path.join(agent, 'skills-backup-' + id, 'keep'), id);
  }
  await assert.rejects(prepareBundle(f.bundle, f.workspace), /recovery_ambiguous/);
  assert.equal(await readFile(path.join(agent, 'skills-backup-1/keep'), 'utf8'), '1');
  await assert.rejects(readFile(path.join(agent, 'skills/SKILL.md')));
});

test('backup cleanup failure after publication does not turn readiness into failure', async t => {
  const f = await fixture(t);
  const child = spawnSync(process.execPath, ['--input-type=module', '-e', `
    import fs from 'node:fs';
    import { syncBuiltinESMExports } from 'node:module';
    const rm = fs.promises.rm;
    fs.promises.rm = async (entry, options) => {
      if (entry.split('/').at(-1).startsWith('txn-')) throw new Error('cleanup failure');
      return rm(entry, options);
    };
    syncBuiltinESMExports();
    const { prepareBundle } = await import(${JSON.stringify(new URL('./skill-bundle.mjs', import.meta.url).href)});
    console.log(JSON.stringify(await prepareBundle(${JSON.stringify(f.bundle)}, ${JSON.stringify(f.workspace)})));
  `], { encoding: 'utf8' });
  assert.equal(child.status, 0, child.stderr);
  assert.equal(validateReady(child.stdout).status, 'ready');
  assert.equal((await prepareBundle(f.bundle, f.workspace)).status, 'ready');
});
