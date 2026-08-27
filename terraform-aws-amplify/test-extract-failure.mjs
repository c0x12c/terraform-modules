#!/usr/bin/env node
// Offline: no creds, no network. test-runner.mjs is the live smoke test.
//   node --test terraform-aws-amplify/test-extract-failure.mjs
//
// Fixtures are lifted from real job logs, awkward parts included - both were found by
// running this against a live failed build, not imagined.

import test from 'node:test';
import assert from 'node:assert/strict';
import { extractFailureDetail } from './files/index.mjs';

// The kernel kill logs as [WARNING]; [ERROR] carries only "exit code 137".
const OOM_LOG = [
  '2026-01-01T00:00:00.000Z [INFO]: Output location: /codebuild/output/src/dist/browser',
  '2026-01-01T00:00:01.000Z [WARNING]: - Generating server application bundles (phase: setup)...',
  '2026-01-01T00:00:02.000Z [WARNING]: Components styles sourcemaps are not generated when styles optimization is enabled.',
  '2026-01-01T00:02:47.418Z [WARNING]: 1320 Killed                  npm run build:ssr:development',
  '2026-01-01T00:02:47.596Z [ERROR]: !!! Build failed',
  '2026-01-01T00:02:47.596Z [INFO]: Please read more about Amplify Hosting support for SSR frameworks.',
  '2026-01-01T00:02:47.596Z [ERROR]: !!! Error: Command failed with exit code 137',
  '2026-01-01T00:02:47.596Z [INFO]: # Starting environment caching...',
  '2026-01-01T00:02:47.597Z [INFO]: # Environment caching completed',
].join('\n');

const SUCCESS_LOG = [
  '2026-01-01T00:00:00.000Z [WARNING]: Components styles sourcemaps are not generated.',
  '2026-01-01T00:00:01.000Z [INFO]: ## Build completed successfully',
  '2026-01-01T00:00:02.000Z [INFO]: # Caching completed',
].join('\n');

test('names the cause, not just the exit code', () => {
  const result = extractFailureDetail(OOM_LOG);
  assert.equal(result.source, 'error-lines');
  assert.match(result.text, /Killed {2,}npm run build:ssr:development/);
  assert.match(result.text, /exit code 137/);
});

test('stops at the last error so trailing chatter stays out', () => {
  const result = extractFailureDetail(OOM_LOG);
  assert.ok(!result.text.includes('Environment caching completed'));
});

test('does not reach back past the context window', () => {
  const result = extractFailureDetail(OOM_LOG, { contextLines: 1 });
  assert.ok(result.text.includes('Killed'));
  assert.ok(!result.text.includes('Output location'));
});

test('a log with no error marker is reported as a tail, not as the failure', () => {
  const result = extractFailureDetail(SUCCESS_LOG);
  assert.equal(result.source, 'log-tail');
});

test('an empty body renders nothing rather than an empty code block', () => {
  // A cancelled DEPLOY step exposes a logUrl that serves zero bytes.
  for (const empty of ['', '   \n  \n\t\n']) {
    assert.equal(extractFailureDetail(empty), null);
  }
});

test('a missing or non-string log renders nothing', () => {
  for (const value of [null, undefined, 123, {}, []]) {
    assert.equal(extractFailureDetail(value), null);
  }
});

test('caps both lines and characters so build env cannot flood the channel', () => {
  const flood = Array.from(
    { length: 400 },
    (_, i) => `2026-01-01T00:00:00Z [ERROR]: line ${i} ${'x'.repeat(80)}`,
  ).join('\n');
  const result = extractFailureDetail(flood);
  assert.ok(result.text.split('\n').length <= 12, 'line cap');
  assert.ok(result.text.length <= 1500, 'char cap');
});

test('keeps the end of an oversized block, where the cause is', () => {
  const flood = Array.from(
    { length: 50 },
    (_, i) => `2026-01-01T00:00:00Z [ERROR]: ${'x'.repeat(200)} marker${i}`,
  ).join('\n');
  const result = extractFailureDetail(flood);
  assert.ok(result.text.includes('marker49'));
  assert.ok(!result.text.includes('marker0 '));
});
