// Minimal read-only Terraform module registry implementing modules.v1.
// Fully anonymous. Serves modules packed as tarballs in an R2 bucket.
//
// Protocol (verified against developer.hashicorp.com/terraform/internals/module-registry-protocol):
//   GET /.well-known/terraform.json
//   GET /v1/modules/:ns/:name/:provider/versions          -> {"modules":[{"versions":[{"version":"x"}]}]}
//   GET /v1/modules/:ns/:name/:provider/:version/download  -> 204 + X-Terraform-Get header
//
// R2 layout (binding: BUCKET):
//   index.json                                   {"c0x12c/rds/aws": ["0.6.5","0.6.6"], ...}
//   modules/<ns>/<name>/<provider>/<version>.tar.gz   (module files at archive root)
//
// Resilience: R2 reads can transiently fail. A bare get()+JSON.parse with no
// retry surfaces as an opaque 500 and breaks `terraform init` (it only retries
// twice). So: retry R2 gets, cache index.json (it changes only on release), and
// return a retryable 503 — never an unhandled throw — on any unexpected error.

const DISCOVERY = { "modules.v1": "/v1/modules/" };
const jsonRes = (o, status = 200) =>
  new Response(JSON.stringify(o), { status, headers: { "content-type": "application/json" } });

// Retry transient R2 get failures. Returns the object (possibly null if the key
// is genuinely absent); throws only after exhausting retries on real errors.
async function r2Get(env, key, tries = 3) {
  let lastErr;
  for (let i = 0; i < tries; i++) {
    try {
      return await env.BUCKET.get(key);
    } catch (e) {
      lastErr = e;
      await new Promise((r) => setTimeout(r, 50 * (i + 1)));
    }
  }
  throw lastErr;
}

// In-isolate cache for index.json. It changes only when a module is released,
// so a short TTL keeps versions lookups off R2 (fewer transient-failure windows)
// while staying fresh enough for pinned consumers.
let INDEX_CACHE = null; // { data, ts }
const INDEX_TTL_MS = 60_000;

async function loadIndex(env) {
  const now = Date.now();
  if (INDEX_CACHE && now - INDEX_CACHE.ts < INDEX_TTL_MS) return INDEX_CACHE.data;
  const obj = await r2Get(env, "index.json");
  if (!obj) return null;
  const data = JSON.parse(await obj.text());
  INDEX_CACHE = { data, ts: now };
  return data;
}

export default {
  async fetch(req, env) {
    try {
      const url = new URL(req.url);
      const p = url.pathname;

      if (p === "/.well-known/terraform.json") return jsonRes(DISCOVERY);

      // List versions
      let m = p.match(/^\/v1\/modules\/([^/]+)\/([^/]+)\/([^/]+)\/versions$/);
      if (m) {
        const idx = await loadIndex(env);
        if (!idx) return jsonRes({ errors: ["registry unavailable"] }, 503);
        const vs = idx[`${m[1]}/${m[2]}/${m[3]}`];
        if (!vs) return jsonRes({ errors: ["Not Found"] }, 404);
        return jsonRes({ modules: [{ versions: vs.map((v) => ({ version: v })) }] });
      }

      // Download: 204 + X-Terraform-Get pointing at the archive route on this same host
      m = p.match(/^\/v1\/modules\/([^/]+)\/([^/]+)\/([^/]+)\/([^/]+)\/download$/);
      if (m) {
        const get = `${url.origin}/v1/modules/${m[1]}/${m[2]}/${m[3]}/${m[4]}/archive.tar.gz`;
        return new Response(null, { status: 204, headers: { "X-Terraform-Get": get } });
      }

      // Serve the tarball straight from R2 (module files at archive root -> no //subdir needed)
      m = p.match(/^\/v1\/modules\/([^/]+)\/([^/]+)\/([^/]+)\/([^/]+)\/archive\.tar\.gz$/);
      if (m) {
        const key = `modules/${m[1]}/${m[2]}/${m[3]}/${m[4]}.tar.gz`;
        const obj = await r2Get(env, key);
        if (!obj) return new Response("not found", { status: 404 });
        return new Response(obj.body, { headers: { "content-type": "application/gzip" } });
      }

      return new Response("not found", { status: 404 });
    } catch (e) {
      // Retryable: terraform treats 5xx as transient and retries.
      return jsonRes({ errors: ["internal error", String((e && e.message) || e)] }, 503);
    }
  },
};
