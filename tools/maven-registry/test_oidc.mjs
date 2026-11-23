import assert from "node:assert/strict";
import { verifyGithubOidc, resetOidcState } from "./oidc.js";

const algorithm = { name: "RSASSA-PKCS1-v1_5", modulusLength: 2048,
  publicExponent: new Uint8Array([1, 0, 1]), hash: "SHA-256" };
const pair = await crypto.subtle.generateKey(algorithm, true, ["sign", "verify"]);
const other = await crypto.subtle.generateKey(algorithm, true, ["sign", "verify"]);
const jwk = { ...await crypto.subtle.exportKey("jwk", pair.publicKey), kid: "known", alg: "RS256" };
let calls = 0, time = 1_800_000_000_000;
const opts = { audience: "registry", allowedOwners: ["example"], allowedRepos: ["example/repo"],
  now: () => time, fetchImpl: async (url) => {
    assert.equal(url, "https://token.actions.githubusercontent.com/.well-known/jwks");
    calls++;
    return { ok: true, json: async () => ({ keys: [jwk] }) };
  } };
const claims = { iss: "https://token.actions.githubusercontent.com", aud: "registry",
  exp: time / 1000 + 300, nbf: time / 1000 - 10, repository_owner: "example",
  repository: "example/repo", ref: "refs/heads/master", event_name: "push" };
const encode = (value) => Buffer.from(JSON.stringify(value)).toString("base64url");
async function token(delta = {}, header = {}, key = pair.privateKey) {
  const body = `${encode({ alg: "RS256", kid: "known", ...header })}.${encode({ ...claims, ...delta })}`;
  const signature = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(body));
  return `${body}.${Buffer.from(signature).toString("base64url")}`;
}
let checks = 0;
async function reject(jwt, reason, options = opts) {
  const result = await verifyGithubOidc(jwt, options);
  assert.deepEqual(result, { ok: false, reason });
  assert.ok(!result.reason.includes(jwt));
  checks++;
}
resetOidcState();
const valid = await token();
const concurrent = Array.from({ length: 5 });
const delayed = { ...opts, fetchImpl: async (url) => {
  await new Promise((resolve) => setTimeout(resolve, 0));
  return opts.fetchImpl(url);
} };
const successes = await Promise.all(concurrent.map(() => verifyGithubOidc(valid, delayed)));
assert.deepEqual(successes, concurrent.map(() => ({ ok: true, claims })));
assert.equal(calls, 1, "cold concurrent verification shares one fetch");
resetOidcState();
calls = 0;
assert.deepEqual(await verifyGithubOidc(valid, opts), { ok: true, claims });
assert.equal(calls, 1);
await reject(await token({}, {}, other.privateKey), "bad_signature");
await reject(await token({}, { alg: "none" }), "alg_none");
await reject(await token({}, { alg: "HS256" }), "unsupported_alg");
for (const [delta, reason] of [
  [{ iss: "wrong" }, "wrong_issuer"], [{ aud: "wrong" }, "wrong_audience"],
  [{ exp: time / 1000 - 61 }, "expired"], [{ nbf: time / 1000 + 61 }, "not_yet_valid"],
  [{ repository_owner: "other" }, "owner_not_allowed"], [{ repository: "example/other" }, "repo_not_allowed"],
  [{ ref: "refs/heads/feature" }, "ref_not_allowed"],
  [{ ref: "refs/tags/v1" }, "ref_not_allowed"],
  [{ event_name: "pull_request" }, "pull_request"],
  [{ event_name: "pull_request_target" }, "pull_request_target"],
]) await reject(await token(delta), reason);
await reject("two.parts", "malformed_token");
await reject("%.e30.AA", "invalid_encoding");
assert.equal(calls, 1, "known keys stay cached");
for (const event_name of ["workflow_run", "issue_comment", "schedule", "release", "repository_dispatch"]) {
  await reject(await token({ event_name }), "event_not_allowed");
}
for (const event_name of ["push", "workflow_dispatch"]) {
  assert.equal((await verifyGithubOidc(await token({ ref: "refs/heads/main", event_name }), opts)).ok, true);
}
assert.equal((await verifyGithubOidc(await token({ exp: time / 1000 - 59, nbf: time / 1000 + 60 }), opts)).ok, true);
resetOidcState();
calls = 0;
await reject(valid, "repos_not_configured", { ...opts, allowedRepos: [] });
assert.equal(calls, 0, "missing repository configuration never fetches keys");
await reject(await token({}, { kid: "cold-missing" }), "unknown_kid");
assert.equal(calls, 1, "cold unknown kid makes only one fetch");
resetOidcState();
calls = 0;
await verifyGithubOidc(valid, opts);
for (let i = 0; i < 50; i++) await reject(await token({}, { kid: `missing-${i}` }), "unknown_kid");
assert.equal(calls, 1, "unknown kids do not fetch inside the first window");
time += 60_001;
await reject(await token({}, { kid: "missing-later" }), "unknown_kid");
assert.equal(calls, 2, "unknown kid refreshes after the window");
await reject(await token({}, { kid: "missing-again" }), "unknown_kid");
assert.equal(calls, 2, "refresh starts a new throttle window");
time += 60_001;
const rotated = { ...await crypto.subtle.exportKey("jwk", other.publicKey), kid: "rotated", alg: "RS256" };
assert.equal((await verifyGithubOidc(await token({}, { kid: "rotated" }, other.privateKey),
  { ...opts, fetchImpl: async () => { calls++; return { ok: true, json: async () => ({ keys: [jwk, rotated] }) }; } })).ok, true);
assert.equal(calls, 3, "rotated key is fetched and verifies after the window");
resetOidcState();
await verifyGithubOidc(valid, opts);
calls = 0;
time += 600_000;
await verifyGithubOidc(await token({ exp: time / 1000 + 300 }), opts);
assert.equal(calls, 1, "cache expires at ten minutes");
resetOidcState();
calls = 0;
const failing = { ...opts, fetchImpl: async () => {
  calls++;
  await new Promise((resolve) => setTimeout(resolve, 0));
  throw new Error(valid);
} };
await Promise.all(concurrent.map(() => reject(valid, "jwks_unavailable", failing)));
assert.equal(calls, 1, "cold concurrent failures share one fetch");
for (let i = 0; i < 20; i++) await reject(valid, "jwks_unavailable", failing);
assert.equal(calls, 1, "failed fetch attempts are throttled");
time += 60_001;
await reject(valid, "jwks_unavailable", failing);
assert.equal(calls, 2, "failed fetch retries after the window");
resetOidcState();
await reject(valid, "jwks_unavailable", { ...opts, fetchImpl: async () => ({ ok: false }) });
await reject(valid, "invalid_input", null);
console.log(`ALL PASS (${checks} rejection checks, signatures, policy, cache and rotation)`);
