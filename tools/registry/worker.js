// Minimal read-only Terraform module registry implementing modules.v1.
// Fully anonymous. Serves modules packed as tarballs in an R2 bucket.
//
// Protocol (verified against developer.hashicorp.com/terraform/internals/module-registry-protocol):
//   GET /.well-known/terraform.json
//   GET /v1/modules/:ns/:name/:provider/versions          -> {"modules":[{"versions":[{"version":"x"}]}]}
//   GET /v1/modules/:ns/:name/:provider/:version/download  -> 204 + X-Terraform-Get header
//
// Human / operational surface (not part of the protocol):
//   GET /            -> HTML landing page + browsable module catalog
//   GET /healthz     -> readiness probe (200 if index.json loads, else 503)
//   GET /robots.txt  -> disallow crawling the API paths
//   GET /favicon.ico -> 204 (suppress browser 404 noise)
//   any other path   -> JSON 404 for /v1/ + /.well-known/ shapes, HTML 404 otherwise
//
// R2 layout (binding: BUCKET):
//   index.json                                   {"c0x12c/rds/aws": ["0.6.5","0.6.6"], ...}
//   modules/<ns>/<name>/<provider>/<version>.tar.gz   (module files at archive root)
//
// Resilience: R2 reads can transiently fail. A bare get()+JSON.parse with no
// retry surfaces as an opaque 500 and breaks `terraform init` (it only retries
// twice). So: retry R2 gets, cache index.json (it changes only on release), and
// return a retryable 503 — never an unhandled throw — on any unexpected error.

const REGISTRY_HOST = "terraform.c0x12c.com";
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

const esc = (s) =>
  String(s).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

// Numeric semver-ish compare (descending). Prerelease tags are stripped, so the
// ordering is for display only — pinned consumers always go through the protocol.
function semverParts(v) {
  return String(v)
    .replace(/^v/, "")
    .split("-")[0]
    .split(".")
    .map((x) => parseInt(x, 10) || 0);
}
function latestVersion(versions) {
  return [...versions].sort((a, b) => {
    const pa = semverParts(a);
    const pb = semverParts(b);
    for (let i = 0; i < 3; i++) {
      if ((pa[i] || 0) !== (pb[i] || 0)) return (pb[i] || 0) - (pa[i] || 0);
    }
    return 0;
  })[0];
}

function landingHtml(idx) {
  const keys = idx ? Object.keys(idx).sort() : [];
  const example =
    idx && idx["c0x12c/rds/aws"]
      ? { key: "c0x12c/rds/aws", v: latestVersion(idx["c0x12c/rds/aws"]) }
      : { key: "c0x12c/<module>/<provider>", v: "x.y.z" };
  const rows = keys
    .map((k) => {
      const latest = esc(latestVersion(idx[k]));
      const count = idx[k].length;
      return `<tr><td><code>${esc(REGISTRY_HOST)}/${esc(k)}</code></td><td class="v">${latest}</td><td class="n">${count}</td></tr>`;
    })
    .join("");
  const catalog = keys.length
    ? `<input id="q" class="search" type="search" placeholder="Filter ${keys.length} modules…"
        autocomplete="off" autocapitalize="off" spellcheck="false" aria-label="Filter modules">
    <table>
      <thead><tr><th>Source</th><th>Latest</th><th>Versions</th></tr></thead>
      <tbody id="rows">${rows}</tbody>
    </table>
    <p id="empty" class="muted" hidden>No modules match.</p>`
    : `<p class="muted">Catalog temporarily unavailable — try again shortly.</p>`;
  const snippet = esc(
    `module "example" {\n  source  = "${REGISTRY_HOST}/${example.key}"\n  version = "${example.v}"\n}`
  );
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>c0x12c Terraform Module Registry</title>
<style>
  :root { color-scheme: light dark; --fg:#1c1e21; --muted:#6b7280; --bg:#ffffff; --card:#f6f7f9; --border:#e3e6ea; --accent:#5b3bd4; }
  @media (prefers-color-scheme: dark) {
    :root { --fg:#e6e8eb; --muted:#9aa3ad; --bg:#0f1115; --card:#171a20; --border:#272b33; --accent:#a98bff; }
  }
  * { box-sizing: border-box; }
  body { margin:0; background:var(--bg); color:var(--fg);
    font:15px/1.55 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif; }
  .wrap { max-width:880px; margin:0 auto; padding:48px 20px 72px; }
  h1 { font-size:1.7rem; margin:0 0 4px; letter-spacing:-0.01em; }
  .sub { color:var(--muted); margin:0 0 28px; }
  h2 { font-size:1rem; text-transform:uppercase; letter-spacing:0.04em; color:var(--muted); margin:32px 0 12px; }
  pre { background:var(--card); border:1px solid var(--border); border-radius:10px;
    padding:16px 18px; overflow:auto; margin:0; }
  code { font:13px/1.5 ui-monospace,SFMono-Regular,Menlo,Consolas,monospace; }
  .note { color:var(--muted); margin:12px 0 0; font-size:13.5px; }
  table { width:100%; border-collapse:collapse; font-size:13.5px; margin-top:4px; }
  th, td { text-align:left; padding:7px 10px; border-bottom:1px solid var(--border); }
  th { color:var(--muted); font-weight:600; font-size:12px; text-transform:uppercase; letter-spacing:0.03em; }
  td.v, th:nth-child(2) { white-space:nowrap; }
  td.n, th:nth-child(3) { text-align:right; color:var(--muted); }
  tbody tr:hover { background:var(--card); }
  a { color:var(--accent); }
  .muted { color:var(--muted); }
  .search { width:100%; margin:4px 0 12px; padding:9px 12px; border-radius:8px;
    border:1px solid var(--border); background:var(--card); color:var(--fg);
    font:13.5px/1.5 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif; }
  .search:focus { outline:none; border-color:var(--accent); }
</style>
</head>
<body>
<div class="wrap">
  <h1>c0x12c Terraform Module Registry</h1>
  <p class="sub">Self-hosted, public, anonymous. Namespace <code>c0x12c</code> · ${keys.length || "—"} modules.</p>

  <h2>Usage</h2>
  <pre><code>${snippet}</code></pre>
  <p class="note">No authentication required — <code>terraform init</code> resolves modules over HTTPS.
  Service discovery: <a href="/.well-known/terraform.json">/.well-known/terraform.json</a>.</p>

  <h2>Modules</h2>
  ${catalog}
</div>
<script>
(function () {
  var q = document.getElementById("q");
  if (!q) return;
  var rows = Array.prototype.slice.call(document.querySelectorAll("#rows tr"));
  var empty = document.getElementById("empty");
  rows.forEach(function (r) { r.dataset.k = (r.textContent || "").toLowerCase(); });
  q.addEventListener("input", function () {
    var term = q.value.trim().toLowerCase();
    var shown = 0;
    rows.forEach(function (r) {
      var hit = !term || r.dataset.k.indexOf(term) !== -1;
      r.hidden = !hit;
      if (hit) shown++;
    });
    if (empty) empty.hidden = shown !== 0;
  });
})();
</script>
</body>
</html>`;
}

function notFoundHtml() {
  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Not found</title>
<style>body{margin:0;background:#0f1115;color:#e6e8eb;color-scheme:light dark;
font:15px/1.6 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif}
@media(prefers-color-scheme:light){body{background:#fff;color:#1c1e21}}
.w{max-width:640px;margin:0 auto;padding:64px 20px}a{color:#a98bff}
code{font:13px ui-monospace,Menlo,monospace}</style></head>
<body><div class="w">
<h1>404 — Not found</h1>
<p>This is the c0x12c self-hosted Terraform module registry. The page you
requested isn't a registry endpoint.</p>
<p>See the <a href="/">module catalog</a>, or use a module via:</p>
<pre><code>source  = "${REGISTRY_HOST}/c0x12c/&lt;module&gt;/&lt;provider&gt;"</code></pre>
</div></body></html>`;
}

export default {
  async fetch(req, env) {
    try {
      const url = new URL(req.url);
      const p = url.pathname;

      if (p === "/.well-known/terraform.json") return jsonRes(DISCOVERY);

      // Landing page + browsable catalog. Best-effort: render the shell even if
      // the index can't be loaded, so `/` never hard-fails for a human visitor.
      if (p === "/" || p === "/index.html") {
        let idx = null;
        try {
          idx = await loadIndex(env);
        } catch (e) {
          idx = null;
        }
        return new Response(landingHtml(idx), {
          headers: { "content-type": "text/html; charset=utf-8" },
        });
      }

      // Readiness probe: 200 only when the critical dependency (index.json) loads.
      if (p === "/healthz") {
        try {
          const idx = await loadIndex(env);
          if (!idx) return jsonRes({ status: "unavailable", reason: "index.json not loadable" }, 503);
          return jsonRes({ status: "ok", modules: Object.keys(idx).length });
        } catch (e) {
          return jsonRes({ status: "unavailable", reason: String((e && e.message) || e) }, 503);
        }
      }

      if (p === "/robots.txt") {
        return new Response("User-agent: *\nDisallow: /v1/\n", {
          headers: { "content-type": "text/plain; charset=utf-8" },
        });
      }

      if (p === "/favicon.ico") return new Response(null, { status: 204 });

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
        if (!obj) return jsonRes({ errors: ["Not Found"] }, 404);
        return new Response(obj.body, { headers: { "content-type": "application/gzip" } });
      }

      // Unmatched: JSON for protocol-shaped paths (terraform-facing), HTML otherwise.
      if (p.startsWith("/v1/") || p.startsWith("/.well-known/")) {
        return jsonRes({ errors: ["Not Found"] }, 404);
      }
      return new Response(notFoundHtml(), {
        status: 404,
        headers: { "content-type": "text/html; charset=utf-8" },
      });
    } catch (e) {
      // Retryable: terraform treats 5xx as transient and retries.
      return jsonRes({ errors: ["internal error", String((e && e.message) || e)] }, 503);
    }
  },
};
