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
const bucket = {
  async get(key) {
    if (key === "index.json") return { async text() { return INDEX; } };
    if (TARBALL_KEYS.has(key)) return { body: "tarbytes", async text() { return "tarbytes"; } };
    return null; // changelogs etc. absent -> graceful fallback
  },
};

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
  const { ctx, settle } = makeCtx();
  const env = { BUCKET: bucket, DB: makeD1(db) };
  const call = (p) => worker.fetch(new Request(reqUrl(p)), env, ctx);

  // (a) Increments: two pulls of 0.6.5, one of 0.6.6. Validates the upsert.
  const r1 = await call(`${ARCHIVE}/0.6.5/archive.tar.gz`);
  const r2 = await call(`${ARCHIVE}/0.6.5/archive.tar.gz`);
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
  assert.match(landing, /Downloads/, "landing should have a Downloads column/stat");
  ok("landing SUM/GROUP BY end-to-end: module total 3");

  // (c) Module detail: per-version counts + module total.
  const detail = await (await call("/modules/c0x12c/rds/aws")).text();
  assert.match(detail, />2 ↓</, "module detail should show 2 downloads for 0.6.5 row");
  assert.match(detail, />1 ↓</, "module detail should show 1 download for 0.6.6 row");
  assert.match(detail, /3 downloads/, "module detail should show module total 3 downloads");
  ok("module detail shows per-version counts and total");

  // (d) Version detail: single count.
  const vdetail = await (await call("/modules/c0x12c/rds/aws/0.6.5")).text();
  assert.match(vdetail, /2 downloads/, "version detail should show 2 downloads");
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
  assert.match(vdetail2, /0 downloads/, "no-DB version detail shows 0");
  ok("graceful degrade: no DB binding -> downloads serve, counts read 0");

  console.log(`\nALL PASS (${passed} checks)`);
}

main().catch((e) => {
  console.error("\nFAIL:", e && e.stack ? e.stack : e);
  process.exit(1);
});
