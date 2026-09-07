import assert from 'node:assert/strict';
import { mkdtemp, mkdir, readFile, realpath, rm, symlink, writeFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { buildBundle, prepareBundle, verifyBundle } from './skill-bundle.mjs';

const revision = 'a'.repeat(40);
async function fixture(t) {
  const root = await mkdtemp(path.join(await realpath(os.tmpdir()), 'skill-bundle-test-'));
  t.after(() => rm(root, { recursive: true, force: true }));
  const source = path.join(root, 'source');
  const bundle = path.join(root, 'bundle');
  const workspace = path.join(root, 'workspace');
  const skill = path.join(source, 'skills/sealos-deploy');
  await mkdir(path.join(skill, 'references'), { recursive: true });
  await writeFile(path.join(skill, 'SKILL.md'), '---\nname: sealos-deploy\ndescription: Deploy applications.\n---\n# Deploy');
  await writeFile(path.join(skill, 'references/guide.md'), 'offline guide');
  await buildBundle(source, bundle, revision);
  return { root, source, bundle, workspace, skill };
}

test('offline preparation is repeatable, copies resources and preserves unrelated project files', async t => {
  const f = await fixture(t);
  const custom = path.join(f.workspace, '.agents/skills/custom');
  await mkdir(custom, { recursive: true });
  await writeFile(path.join(custom, 'SKILL.md'), 'user skill');
  await writeFile(path.join(f.workspace, 'skills-lock.json'), 'user lock');
  const first = await prepareBundle(f.bundle, f.workspace);
  assert.equal(first.status, 'ready');
  assert.equal(first.revision, revision);
  assert.equal(first.skillCount, 1);
  assert.match(first.digest, /^[a-f0-9]{64}$/);
  assert.deepEqual(await prepareBundle(f.bundle, f.workspace), first);
  assert.equal(await readFile(path.join(f.workspace, '.agents/skills/sealos-deploy/references/guide.md'), 'utf8'), 'offline guide');
  assert.equal(await readFile(path.join(custom, 'SKILL.md'), 'utf8'), 'user skill');
  assert.equal(await readFile(path.join(f.workspace, 'skills-lock.json'), 'utf8'), 'user lock');
});

test('tampered bundle fails before touching workspace', async t => {
  const f = await fixture(t);
  await prepareBundle(f.bundle, f.workspace);
  await writeFile(path.join(f.bundle, 'skills/sealos-deploy/SKILL.md'), 'corrupt');
  await assert.rejects(prepareBundle(f.bundle, f.workspace), /bundle_integrity_failed/);
  assert.match(await readFile(path.join(f.workspace, '.agents/skills/sealos-deploy/SKILL.md'), 'utf8'), /# Deploy/);
});

test('manifest must enumerate unique skills and require deployment entry', async t => {
  const f = await fixture(t);
  const file = path.join(f.bundle, 'manifest.json');
  const manifest = JSON.parse(await readFile(file, 'utf8'));
  await writeFile(file, JSON.stringify({ ...manifest, skills: [] }));
  await assert.rejects(verifyBundle(f.bundle), /invalid_manifest/);
  await writeFile(file, JSON.stringify({ ...manifest, skills: ['sealos-deploy', 'sealos-deploy'] }));
  await assert.rejects(verifyBundle(f.bundle), /invalid_manifest/);
});

test('repository symlinks cannot redirect Skill writes', async t => {
  const f = await fixture(t);
  const outside = path.join(f.root, 'outside');
  await mkdir(f.workspace);
  await mkdir(outside);
  await writeFile(path.join(outside, 'keep'), 'unchanged');
  await symlink(outside, path.join(f.workspace, '.agents'));
  await assert.rejects(prepareBundle(f.bundle, f.workspace), /workspace_symlink/);
  assert.equal(await readFile(path.join(outside, 'keep'), 'utf8'), 'unchanged');
});

test('nested workspace symlinks and bundle symlinks are rejected', async t => {
  const f = await fixture(t);
  const target = path.join(f.workspace, '.agents/skills/custom');
  await mkdir(target, { recursive: true });
  await symlink(f.skill, path.join(target, 'link'));
  await assert.rejects(prepareBundle(f.bundle, f.workspace), /bundle_symlink/);
  await symlink(f.skill, path.join(f.bundle, 'skills/link'));
  await assert.rejects(verifyBundle(f.bundle), /bundle_symlink/);
});

test('invalid source metadata and non-commit revisions fail at build time', async t => {
  const f = await fixture(t);
  await assert.rejects(buildBundle(f.source, path.join(f.root, 'other'), 'main'), /invalid_revision/);
  await writeFile(path.join(f.skill, 'SKILL.md'), '# no metadata');
  await assert.rejects(buildBundle(f.source, path.join(f.root, 'other'), revision), /invalid_skill_metadata/);
});

test('staging failure leaves the previous workspace intact', async t => {
  const f = await fixture(t);
  await prepareBundle(f.bundle, f.workspace);
  await mkdir(path.join(f.workspace, `.agents/skills-backup-${process.pid}`));
  await assert.rejects(prepareBundle(f.bundle, f.workspace), { code: 'EEXIST' });
  assert.match(await readFile(path.join(f.workspace, '.agents/skills/sealos-deploy/SKILL.md'), 'utf8'), /# Deploy/);
});
