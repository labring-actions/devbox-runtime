import assert from 'node:assert/strict';
import { mkdtemp, mkdir, readFile, realpath, rename, rm, symlink, writeFile } from 'node:fs/promises';
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
  await rename(target, path.join(f.workspace, '.agents/skills-backup-99999'));
  await mkdir(path.join(f.workspace, '.agents/skills-stage-99999'));
  assert.equal((await prepareBundle(f.bundle, f.workspace)).status, 'ready');
  assert.equal(await readFile(path.join(target, 'custom/keep'), 'utf8'), 'user content');
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
