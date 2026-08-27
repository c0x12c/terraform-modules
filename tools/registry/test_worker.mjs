// Zero-dependency test for the registry worker's download-stats feature.
// Drives the REAL exported handler against REAL SQLite (node:sqlite, Node 22+)
// so the upsert and SUM/GROUP BY queries are actually validated - not mocked.
//
// Run from tools/registry/:   node test_worker.mjs
// (node:sqlite prints a harmless ExperimentalWarning to stderr; ignore it.)
import { DatabaseSync } from "node:sqlite";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import worker from "./worker.js";

// --- D1-shaped adapter over a real in-memory SQLite database ---------------
class Stmt {
  constructor(db, sql) {
    this.stmt = db.prepare(sql);
    this.args = [];
  }
  bind(...a) {
    this.args = a;
    return this;
  }
  async run() {
    this.stmt.run(...this.args);
    return { success: true };
  }
  async all() {
    return { results: this.stmt.all(...this.args) };
  }
  async first() {
    const r = this.stmt.get(...this.args);
    return r ?? null;
  }
}
function makeD1(db) {
  return { prepare: (sql) => new Stmt(db, sql) };
}

// --- Fakes -----------------------------------------------------------------
const INDEX = JSON.stringify({ "c0x12c/rds/aws": ["0.6.6", "0.6.5"] });
const TARBALL_KEYS = new Set([
  "modules/c0x12c/rds/aws/0.6.5.tar.gz",
  "modules/c0x12c/rds/aws/0.6.6.tar.gz",
]);
let bucketGetCount = 0;
const bucket = {
  async get(key) {
    bucketGetCount++;
    if (key === "index.json") return { async text() { return INDEX; } };
    if (TARBALL_KEYS.has(key)) {
      return {
        body: "tarbytes",
        httpEtag: '"etag-tarbytes"',
        async text() { return "tarbytes"; },
      };
    }
    return null; // changelogs etc. absent -> graceful fallback
  },
};

function makeCacheStore() {
  const store = new Map();
  let puts = 0;
  return {
    api: {
      async match(request) {
        // Real Cache API hands back a fresh response each time; returning the stored
        // instance would let one test drain a one-shot body for the next.
        const hit = store.get(request.url);
        return hit ? hit.clone() : null;
      },
      async put(request, response) {
        puts++;
        store.set(request.url, response);
      },
    },
    prime(url, response) {
      store.set(url, response);
    },
    clear() {
      store.clear();
      puts = 0;
    },
    putCount() {
      return puts;
    },
  };
}

function makeCtx() {
  const pending = [];
  return {
    ctx: { waitUntil(p) { pending.push(p); } },
    settle: () => Promise.all(pending.splice(0)),
  };
}

const ARCHIVE = "/v1/modules/c0x12c/rds/aws";
const reqUrl = (p) => "https://terraform.c0x12c.com" + p;

let passed = 0;
function ok(label) {
  passed++;
  console.log("  ✓ " + label);
}

async function main() {
  // Fresh DB with the real schema applied.
  const db = new DatabaseSync(":memory:");
  db.exec(readFileSync(new URL("./schema.sql", import.meta.url), "utf8"));
  const cacheStore = makeCacheStore();
  globalThis.caches = { default: cacheStore.api };
  const { ctx, settle } = makeCtx();
  const env = { BUCKET: bucket, DB: makeD1(db) };
  const call = (p) => worker.fetch(new Request(reqUrl(p)), env, ctx);
  const archiveUrl65 = reqUrl(`${ARCHIVE}/0.6.5/archive.tar.gz`);
  const archiveUrl66 = reqUrl(`${ARCHIVE}/0.6.6/archive.tar.gz`);

  bucketGetCount = 0;
  const archiveRes = await call(`${ARCHIVE}/0.6.5/archive.tar.gz`);
  assert.equal(archiveRes.status, 200);
  assert.equal(archiveRes.headers.get("cache-control"), "public, max-age=86400");
  assert.ok(archiveRes.headers.get("etag"));
  ok("archive response carries cache-control and etag");

  await settle();
  assert.equal(cacheStore.putCount(), 1);
  const cached65 = await cacheStore.api.match(new Request(archiveUrl65));
  assert.equal(cached65.status, 200);
  ok("archive miss writes a 200 response through Cache API");

  const bucketGetsBeforeHit = bucketGetCount;
  cacheStore.prime(
    archiveUrl66,
    new Response("cached-tarbytes", {
      status: 200,
      headers: {
        "content-type": "application/gzip",
        "cache-control": "public, max-age=86400",
        etag: '"etag-cached"',
      },
    })
  );
  const hitRes = await call(`${ARCHIVE}/0.6.6/archive.tar.gz`);
  assert.equal(hitRes.status, 200);
  assert.equal(await hitRes.text(), "cached-tarbytes");
  await settle();
  const cHit = db.prepare("SELECT count(*) AS n FROM downloads WHERE version=?").get("0.6.6");
  assert.equal(cHit.n, 0, "cache hit must not increment downloads");
  assert.equal(bucketGetCount, bucketGetsBeforeHit, "cache hit must not fetch from R2");
  ok("archive cache hit skips R2 fetch and bumpDownload");

  const unavailableEnv = {
    BUCKET: {
      async get() {
        throw new Error("boom");
      },
    },
    DB: makeD1(db),
  };
  const unavailableRes = await worker.fetch(new Request(reqUrl("/healthz")), unavailableEnv, ctx);
  assert.equal(unavailableRes.status, 503);
  assert.equal(unavailableRes.headers.get("retry-after"), "5");
  ok("503 responses carry Retry-After");

  // (a) Increments: two pulls of 0.6.5, one of 0.6.6. Validates the upsert.
  db.exec("DELETE FROM downloads");
  cacheStore.clear();
  const r1 = await call(`${ARCHIVE}/0.6.5/archive.tar.gz`);
  await settle();
  cacheStore.clear();
  const r2 = await call(`${ARCHIVE}/0.6.5/archive.tar.gz`);
  await settle();
  cacheStore.clear();
  const r3 = await call(`${ARCHIVE}/0.6.6/archive.tar.gz`);
  assert.equal(r1.status, 200);
  assert.equal(r2.status, 200);
  assert.equal(r3.status, 200);
  await settle();
  const c65 = db.prepare("SELECT count FROM downloads WHERE module_key=? AND version=?").get("c0x12c/rds/aws", "0.6.5");
  const c66 = db.prepare("SELECT count FROM downloads WHERE module_key=? AND version=?").get("c0x12c/rds/aws", "0.6.6");
  assert.equal(c65.count, 2, "0.6.5 should have 2 downloads");
  assert.equal(c66.count, 1, "0.6.6 should have 1 download");
  ok("upsert increments per (module,version): 0.6.5=2, 0.6.6=1");

  // A non-existent tarball must NOT create a row (counted only after the obj check).
  const r404 = await call(`${ARCHIVE}/9.9.9/archive.tar.gz`);
  assert.equal(r404.status, 404);
  await settle();
  const ghost = db.prepare("SELECT count(*) AS n FROM downloads WHERE version=?").get("9.9.9");
  assert.equal(ghost.n, 0, "phantom version must not be counted");
  ok("missing tarball is not counted (404, no row)");

  // (b) Landing catalog total comes from SUM(count) GROUP BY -> 3 for the module.
  const landing = await (await call("/")).text();
  assert.match(landing, /class="count dlc">3</, "landing catalog cell should show module total 3");
  assert.match(landing, /Pulls/, "landing should have a Pulls column/stat");
  ok("landing SUM/GROUP BY end-to-end: module total 3");

  // (c) Module detail: per-version counts + module total.
  const detail = await (await call("/modules/c0x12c/rds/aws")).text();
  assert.match(detail, />2 ↓</, "module detail should show 2 downloads for 0.6.5 row");
  assert.match(detail, />1 ↓</, "module detail should show 1 download for 0.6.6 row");
  assert.match(detail, /3 pulls/, "module detail should show module total 3 pulls");
  ok("module detail shows per-version counts and total");

  // (d) Version detail: single count.
  const vdetail = await (await call("/modules/c0x12c/rds/aws/0.6.5")).text();
  assert.match(vdetail, /2 pulls/, "version detail should show 2 pulls");
  ok("version detail shows the version count");

  // (e) Graceful degradation: NO DB binding. Downloads still serve; counts read 0.
  const { ctx: ctx2 } = makeCtx();
  const env2 = { BUCKET: bucket }; // env2.DB undefined
  const call2 = (p) => worker.fetch(new Request(reqUrl(p)), env2, ctx2);
  const dr = await call2(`${ARCHIVE}/0.6.5/archive.tar.gz`);
  assert.equal(dr.status, 200, "download must serve with no DB binding");
  assert.equal(await dr.text(), "tarbytes");
  const landing2 = await (await call2("/")).text();
  assert.match(landing2, /class="count dlc">0</, "no-DB landing shows 0 per module");
  const vdetail2 = await (await call2("/modules/c0x12c/rds/aws/0.6.5")).text();
  assert.match(vdetail2, /0 pulls/, "no-DB version detail shows 0");
  ok("graceful degrade: no DB binding -> downloads serve, counts read 0");

  const versionsRes = await call("/v1/modules/c0x12c/rds/aws/versions");
  assert.equal(versionsRes.status, 200);
  assert.deepEqual(await versionsRes.json(), {
    modules: [{ versions: [{ version: "0.6.6" }, { version: "0.6.5" }] }],
  });
  const downloadRes = await call("/v1/modules/c0x12c/rds/aws/0.6.5/download");
  assert.equal(downloadRes.status, 204);
  assert.equal(downloadRes.headers.get("X-Terraform-Get"), archiveUrl65);
  ok("/versions and /download protocol responses stay unchanged");

  await resilience();

  console.log(`\nALL PASS (${passed} checks)`);
}

// --- R2-fault resilience --------------------------------------------------
// A transient R2 read used to 503 every resolve, which Terraform turns into a
// hard failure after two retries. These cover the fallback and, just as much,
// the things that must NOT happen alongside it.

function failingBucket(good) {
  // Serves normally until `broken` is set, then throws on every read.
  const b = {
    broken: false,
    async get(key) {
      if (b.broken) throw new Error("R2 unavailable");
      return good.get(key);
    },
  };
  return b;
}

async function resilience() {
  // Fresh module instance: LAST_GOOD_INDEX is module-scoped, and one of these
  // cases is specifically "no good index was ever seen".
  const fresh = (await import("./worker.js?resilience=1")).default;

  const good = {
    async get(key) {
      if (key === "index.json") return { async text() { return INDEX; } };
      if (TARBALL_KEYS.has(key)) return { body: "tarbytes", httpEtag: '"e"', async text() { return "tarbytes"; } };
      return null;
    },
  };

  // Case 1: R2 broken from the very start - nothing good was ever cached.
  const cold = makeCacheStore();
  globalThis.caches = { default: cold.api };
  const coldCtx = makeCtx();
  const dead = failingBucket(good);
  dead.broken = true;
  const coldRes = await fresh.fetch(new Request(reqUrl(`${ARCHIVE}/versions`)), { BUCKET: dead, INDEX_TTL_MS: 0 }, coldCtx.ctx);
  assert.equal(coldRes.status, 503);
  ok("/versions 503s when R2 fails and no good index was ever seen");

  // Case 2: one good read, then R2 breaks. The resolve must still work.
  const store = makeCacheStore();
  globalThis.caches = { default: store.api };
  const { ctx, settle } = makeCtx();
  const flaky = failingBucket(good);
  // TTL 0: without this the in-isolate cache answers and the stale path below
  // is never reached, so the assertions would pass without testing anything.
  const env2 = { BUCKET: flaky, INDEX_TTL_MS: 0 };

  const warm = await fresh.fetch(new Request(reqUrl(`${ARCHIVE}/versions`)), env2, ctx);
  assert.equal(warm.status, 200);
  assert.equal(warm.headers.get("X-Registry-Stale"), null);
  await settle();
  // /versions must never be edge-cached: the zone rewrites max-age to 4 hours
  // (browser_cache_ttl=14400), and this is the endpoint whose job is showing a
  // new release promptly.
  assert.equal(store.putCount(), 0);
  ok("/versions is never edge-cached, fresh or stale");

  store.clear();
  flaky.broken = true;
  const stale = await fresh.fetch(new Request(reqUrl(`${ARCHIVE}/versions`)), env2, ctx);
  assert.equal(stale.status, 200);
  const staleBody = await stale.json();
  // Must be the real version list, not an empty one. An empty answer reads as
  // "no such module" and surfaces as a version-constraint failure - it looks
  // like a publishing bug rather than an outage.
  assert.deepEqual(staleBody, {
    modules: [{ versions: [{ version: "0.6.6" }, { version: "0.6.5" }] }],
  });
  assert.equal(stale.headers.get("X-Registry-Stale"), "1");
  ok("/versions serves the last good index when R2 fails, and says so");

  await settle();
  assert.equal(store.putCount(), 0);
  ok("a stale /versions response is not written to the edge cache");

  // A module released after the last good read is absent from the fallback. Its
  // 404 must still say "stale", or it is indistinguishable from a module that was
  // never published - the misdiagnosis this whole fallback exists to avoid.
  const missing = await fresh.fetch(
    new Request(reqUrl("/v1/modules/c0x12c/brand-new/aws/versions")), env2, ctx
  );
  assert.equal(missing.status, 404);
  assert.equal(missing.headers.get("X-Registry-Stale"), "1");
  ok("a 404 served from the stale index still carries the stale marker");

  // healthz reports ORIGIN health and must stay red while consumers are served.
  const health = await fresh.fetch(new Request(reqUrl("/healthz")), env2, ctx);
  assert.equal(health.status, 503);
  ok("/healthz stays 503 while /versions is serving stale");

  // /download consults no state, so it caches too.
  store.clear();
  flaky.broken = false;
  const dl = await fresh.fetch(new Request(reqUrl(`${ARCHIVE}/0.6.5/download`)), env2, ctx);
  assert.equal(dl.status, 204);
  assert.equal(dl.headers.get("X-Terraform-Get"), reqUrl(`${ARCHIVE}/0.6.5/archive.tar.gz`));
  await settle();
  assert.equal(store.putCount(), 1);
  ok("/download is edge-cached and its header is unchanged");
}

main().catch((e) => {
  console.error("\nFAIL:", e && e.stack ? e.stack : e);
  process.exit(1);
});
