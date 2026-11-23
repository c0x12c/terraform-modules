import assert from "node:assert/strict";
import { makeWorker } from "./worker.js";

const bytes = new Map();
const types = new Map();
let reads = 0, puts = 0, seen, putOptions;
const bucket = {
  async head(key) { reads++; return bytes.has(key) ? { httpEtag: '"test"' } : null; },
  async get(key) { return await this.head(key) ? { body: bytes.get(key), httpEtag: '"test"' } : null; },
  async put(key, body, options) {
    putOptions = options;
    if (options.onlyIf?.etagDoesNotMatch === '*' && bytes.has(key)) return null;
    puts++; types.set(key, options.httpMetadata.contentType); bytes.set(key, await new Response(body).text());
    return { httpEtag: '"test"' };
  },
};
const worker = makeWorker(async (jwt, options) => { seen = { jwt, options }; return { ok: jwt === "jwt" }; });
const basic = "Basic " + btoa("user:jwt"), bearer = "Bearer jwt";
const env = { BUCKET: bucket };
function call(path, method = "GET", auth = basic, body = "one", length = "3", bindings = env) {
  const headers = new Headers();
  if (auth !== null) headers.set("Authorization", auth);
  if (length !== null) headers.set("Content-Length", length);
  // Raw request shape preserves hostile paths that the Request constructor normalizes.
  return worker.fetch({ url: "https://maven.example" + path, method, headers,
    body: new Response(body).body }, bindings);
}
assert.equal((await call("/g/a.jar", "PUT", null)).status, 401);
assert.equal((await call("/g/a.jar", "PUT", "Bearer bad")).status, 401);
assert.equal((await call("/g/x.html", "PUT", null)).status, 401);
for (const name of ["x.html", "x.svg", "x.js", "x.exe", "x"]) {
  const response = await call("/g/" + name, "PUT");
  assert.equal(response.status, 415);
  assert.deepEqual(await response.json(), { error: "Unsupported file type" });
  assert.equal(bytes.size, 0);
  assert.equal(reads, 0);
}
for (const auth of ["Basic !!!", "Basic " + btoa("user:"), "Digest jwt"]) {
  const response = await call("/g/a.jar", "PUT", auth);
  assert.equal(response.status, 401);
  assert.equal(response.headers.get("WWW-Authenticate"), "Basic realm=maven-publish");
}
assert.equal((await call("/g/a.jar", "PUT")).status, 201);
assert.deepEqual(seen, { jwt: "jwt", options: {
  audience: "c0x12c-maven-publish", allowedOwners: ["c0x12c"], allowedRepos: [],
} });
assert.equal((await call("/g/b.jar", "PUT", bearer)).status, 201);
const written = puts;
assert.equal((await call("/g/a.jar", "PUT", basic, "two")).status, 409);
assert.equal(bytes.get("g/a.jar"), "one");
assert.equal(puts, written);
const race = await call("/g/a.jar", "PUT", basic, "two", "3", {
  BUCKET: { ...bucket, async head() { return null; } },
});
assert.equal(race.status, 409);
assert.deepEqual(await race.json(), { error: "Already exists" });
assert.equal(bytes.get("g/a.jar"), "one");
for (const suffix of ["", ".md5", ".sha1", ".sha256", ".sha512"]) {
  const path = "/g/maven-metadata.xml" + suffix;
  assert.equal((await call(path, "PUT")).status, 201);
  assert.equal(Object.hasOwn(putOptions, "onlyIf"), false);
  assert.equal((await call(path, "PUT", bearer, "two")).status, 201);
  assert.equal(Object.hasOwn(putOptions, "onlyIf"), false);
  assert.equal(bytes.get(path.slice(1)), "two");
}
assert.equal((await call("/g/1-SNAPSHOT/a-20260101.123456-1.jar", "PUT")).status, 201);
for (const [path, type] of [["/g/a.jar", "application/java-archive"],
  ["/g/a.pom", "text/plain; charset=utf-8"], ["/g/a.xml", "text/plain; charset=utf-8"], ["/g/a.sha1", "text/plain"],
  ["/g/a.module", "application/json"], ["/g/a.asc", "text/plain"], ["/g/a.aar", "application/octet-stream"],
  ["/g/a.klib", "application/octet-stream"], ["/g/a.tar.gz", "application/octet-stream"],
  ["/g/a.sha256", "text/plain"], ["/g/a.war", "application/octet-stream"], ["/g/a.zip", "application/octet-stream"]]) {
  if (!bytes.has(path.slice(1))) assert.equal((await call(path, "PUT")).status, 201);
  assert.equal(types.get(path.slice(1)), type);
  const response = await call(path);
  assert.equal(response.status, 200);
  assert.equal(response.headers.get("content-type"), type);
  assert.equal(response.headers.get("x-content-type-options"), "nosniff");
  assert.equal(response.headers.get("content-security-policy"), "default-src 'none'; sandbox");
  assert.equal(response.headers.get("etag"), '"test"');
  assert.equal(await response.text(), "one");
}
// XML media types let browsers execute XHTML scripts despite nosniff.
const xhtml = '<html xmlns="http://www.w3.org/1999/xhtml"><script>alert(1)</script></html>';
assert.equal((await call("/g/x.xml", "PUT", basic, xhtml, String(xhtml.length))).status, 201);
assert.equal(types.get("g/x.xml"), "text/plain; charset=utf-8");
const xml = await call("/g/x.xml");
assert.equal(xml.headers.get("content-type"), "text/plain; charset=utf-8");
assert.equal(await xml.text(), xhtml);
const head = await call("/g/a.pom", "HEAD");
assert.equal(head.status, 200);
assert.equal(head.body, null);
assert.equal(head.headers.get("x-content-type-options"), "nosniff");
assert.equal(head.headers.get("content-type"), "text/plain; charset=utf-8");
assert.equal(head.headers.get("content-security-policy"), "default-src 'none'; sandbox");
assert.equal((await call("/g/missing")).status, 404);
const health = await call("/healthz");
assert.equal(health.status, 200);
assert.deepEqual(await health.json(), { status: "ok" });
const deleted = await call("/g/a.jar", "DELETE");
assert.equal(deleted.status, 405);
assert.equal(deleted.headers.get("Allow"), "GET, HEAD, PUT");
assert.equal((await call("/g/c.jar", "PUT", basic, "one", null)).status, 411);
assert.equal((await call("/g/c.jar", "PUT", basic, "one", "104857601")).status, 413);
assert.equal((await call("/g/c.jar", "PUT", basic, "one", "3", { ...env, MAX_BYTES: "2" })).status, 413);
const before = reads;
for (const path of ["/", "/a/../b", "/a/./b", "/a/%2e%2e/b", "/a/%2E%2E/b", "/a//b",
  "/a/b%2fc", "/a/b%5Cc", "/a/b\\c", "/a/b c", "/a/b\0c"]) {
  assert.equal((await call(path)).status, 400, path);
}
assert.equal((await call("/single", "PUT")).status, 400);
assert.equal(reads, before);
for (const method of ["GET", "HEAD", "PUT"]) {
  const broken = { BUCKET: { get() { throw Error("secret"); }, head() { throw Error("secret"); } } };
  const response = await call("/g/a.jar", method, basic, "one", "3", broken);
  assert.equal(response.status, 503);
  assert.deepEqual(await response.json(), { error: "Service unavailable" });
}
console.log("PASS: Maven worker acceptance checks");
