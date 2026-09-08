// Network integration test: read the exact image inputs, not a second test pin.
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtemp, mkdir, readFile, readdir, realpath, rm } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { buildBundle, prepareBundle, verifyBundle } from './skill-bundle.mjs';

const dockerfile = await readFile(new URL('./Dockerfile', import.meta.url), 'utf8');
const repository = dockerfile.match(/^ARG SEALOS_SKILLS_REPOSITORY=(.+)$/m)?.[1];
const revision = dockerfile.match(/^ARG SEALOS_SKILLS_REVISION=([a-f0-9]{40})$/m)?.[1];
assert.equal(repository, 'https://github.com/norberia/sealos-skills-next.git');
assert.ok(revision);
const root = await mkdtemp(path.join(await realpath(os.tmpdir()), 'pinned-skill-test-'));
try {
  const source = path.join(root, 'source');
  const git = args => execFileSync('git', args, { encoding: 'utf8', timeout: 120_000 });
  git(['init', source]);
  git(['-C', source, 'remote', 'add', 'origin', repository]);
  git(['-C', source, 'fetch', '--depth', '1', 'origin', revision]);
  git(['-C', source, 'checkout', '--detach', 'FETCH_HEAD']);
  assert.equal(git(['-C', source, 'rev-parse', 'HEAD']).trim(), revision);
  const plugin = path.join(source, 'plugins/sealos');
  const bundle = path.join(root, 'bundle');
  const workspace = path.join(root, 'workspace');
  await mkdir(workspace);
  await buildBundle(plugin, bundle, revision);
  const manifest = await verifyBundle(bundle);
  assert.deepEqual(manifest.skills, (await readdir(path.join(plugin, 'skills'))).sort());
  const first = await prepareBundle(bundle, workspace);
  assert.equal(first.skillCount, manifest.skills.length);
  assert.deepEqual(await prepareBundle(bundle, workspace), first);
  for (const file of Object.keys(manifest.files)) {
    assert.deepEqual(await readFile(path.join(workspace, '.agents/skills', file)), await readFile(path.join(plugin, 'skills', file)));
  }
  console.log(JSON.stringify({ ...first, fileCount: Object.keys(manifest.files).length }));
} finally {
  await rm(root, { recursive: true, force: true });
}
