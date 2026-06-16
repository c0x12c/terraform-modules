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
// return a retryable 503 - never an unhandled throw - on any unexpected error.

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
// ordering is for display only - pinned consumers always go through the protocol.
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

const STYLE = `
  *{box-sizing:border-box}
  :root{
    color-scheme:light dark;
    --bg:#fbfbfd; --bg-grad:#f2f3f7; --panel:#ffffff; --panel-2:#f6f7fa;
    --border:#e7e9ef; --border-strong:#d7dbe3;
    --fg:#0e1622; --fg-soft:#3a4452; --muted:#697586; --faint:#9aa3b2;
    --accent:#0d9488; --accent-fg:#0b7d72; --accent-soft:rgba(13,148,136,.10);
    --shadow:0 1px 2px rgba(16,24,40,.04),0 12px 32px -16px rgba(16,24,40,.18);
    --mono:"IBM Plex Mono",ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;
    --sans:"IBM Plex Sans",-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
  }
  @media (prefers-color-scheme:dark){
    :root{
      --bg:#080a0e; --bg-grad:#0d1016; --panel:#0f131a; --panel-2:#141925;
      --border:#1c222d; --border-strong:#2a3340;
      --fg:#eef1f6; --fg-soft:#c4cbd7; --muted:#8a93a3; --faint:#5e6776;
      --accent:#2dd4bf; --accent-fg:#5eead4; --accent-soft:rgba(45,212,191,.12);
      --shadow:0 1px 2px rgba(0,0,0,.4),0 18px 44px -22px rgba(0,0,0,.75);
    }
  }
  html{-webkit-text-size-adjust:100%}
  body{margin:0;min-height:100vh;position:relative;background:var(--bg);color:var(--fg);
    font-family:var(--sans);font-size:15px;line-height:1.6;-webkit-font-smoothing:antialiased;
    text-rendering:optimizeLegibility;font-feature-settings:"ss01"}
  body::before{content:"";position:fixed;inset:0;z-index:-2;pointer-events:none;
    background:
      radial-gradient(1100px 540px at 50% -10%, var(--accent-soft), transparent 70%),
      linear-gradient(180deg, var(--bg-grad), var(--bg) 36%)}
  body::after{content:"";position:fixed;inset:0;z-index:-1;pointer-events:none;opacity:.45;
    background-image:linear-gradient(var(--border) 1px,transparent 1px),
      linear-gradient(90deg,var(--border) 1px,transparent 1px);
    background-size:46px 46px;
    -webkit-mask-image:radial-gradient(900px 460px at 50% 0%,#000,transparent 72%);
    mask-image:radial-gradient(900px 460px at 50% 0%,#000,transparent 72%)}
  .wrap{max-width:980px;margin:0 auto;padding:0 24px 96px}
  a{color:var(--accent-fg);text-decoration:none}
  a:hover{text-decoration:underline}
  code{font-family:var(--mono);font-feature-settings:"zero"}

  .bar{display:flex;align-items:center;justify-content:space-between;gap:16px;padding:22px 0 6px;flex-wrap:wrap}
  .brand{display:flex;align-items:center;gap:11px;font-weight:600;letter-spacing:-.01em;font-size:15px}
  .logo{width:30px;height:30px;border-radius:9px;display:grid;place-items:center;
    background:var(--accent-soft);border:1px solid var(--border-strong);
    color:var(--accent-fg);font-family:var(--mono);font-weight:600;font-size:14px}
  .tag{font-family:var(--mono);font-size:11.5px;color:var(--muted);border:1px solid var(--border);
    padding:4px 10px;border-radius:999px;background:var(--panel)}

  .hero{padding:26px 0 6px}
  .hero h1{font-size:2.2rem;line-height:1.1;letter-spacing:-.03em;margin:0 0 13px;font-weight:600}
  .hero h1 .accent{color:var(--accent-fg)}
  .lede{color:var(--muted);font-size:1.03rem;max-width:62ch;margin:0}
  .lede code{color:var(--fg-soft);font-size:.92em}
  .stats{display:flex;gap:10px;flex-wrap:wrap;margin:24px 0 2px}
  .stat{background:var(--panel);border:1px solid var(--border);border-radius:13px;
    padding:12px 16px;min-width:106px;box-shadow:var(--shadow)}
  .stat .num{font-family:var(--mono);font-size:1.4rem;font-weight:600;letter-spacing:-.02em;line-height:1}
  .stat .lbl{font-size:11px;text-transform:uppercase;letter-spacing:.08em;color:var(--muted);margin-top:6px}

  .sec{display:flex;align-items:baseline;justify-content:space-between;gap:12px;margin:44px 0 14px}
  .sec h2{font-size:.76rem;text-transform:uppercase;letter-spacing:.13em;color:var(--muted);font-weight:600;margin:0}
  .sec .hint{font-size:12.5px;color:var(--faint);font-family:var(--mono)}

  .snip{position:relative}
  .snip pre{margin:0;background:var(--panel);border:1px solid var(--border);border-radius:14px;
    padding:18px 20px;overflow:auto;box-shadow:var(--shadow)}
  .snip pre code{font-size:13px;line-height:1.75;color:var(--fg-soft)}
  .copy{position:absolute;top:11px;right:11px;font-family:var(--sans);font-size:12px;color:var(--muted);
    background:var(--panel-2);border:1px solid var(--border);border-radius:8px;padding:5px 12px;cursor:pointer;transition:.15s}
  .copy:hover{color:var(--fg);border-color:var(--border-strong)}
  .copy.ok{color:var(--accent-fg);border-color:var(--accent)}
  .note{color:var(--muted);font-size:13.5px;margin:14px 2px 0}

  .search-wrap{position:relative;margin:0 0 14px}
  .search-wrap svg{position:absolute;left:15px;top:50%;transform:translateY(-50%);width:17px;height:17px;color:var(--faint);pointer-events:none}
  .search{width:100%;padding:13px 16px 13px 43px;border-radius:12px;border:1px solid var(--border);
    background:var(--panel);color:var(--fg);font-family:var(--sans);font-size:14.5px;transition:.15s;box-shadow:var(--shadow)}
  .search::placeholder{color:var(--faint)}
  .search:focus{outline:none;border-color:var(--accent);box-shadow:0 0 0 4px var(--accent-soft)}

  .tbl{border:1px solid var(--border);border-radius:14px;overflow:hidden;background:var(--panel);box-shadow:var(--shadow)}
  table{width:100%;border-collapse:collapse}
  thead th{text-align:left;font-size:11px;text-transform:uppercase;letter-spacing:.09em;color:var(--muted);
    font-weight:600;padding:12px 18px;background:var(--panel-2);border-bottom:1px solid var(--border)}
  th.r{text-align:right}
  tbody td{padding:0;border-bottom:1px solid var(--border)}
  tbody tr:last-child td{border-bottom:none}
  tbody tr.link{cursor:pointer;transition:background .12s}
  tbody tr.link:hover{background:var(--accent-soft)}
  tbody tr.link:hover .name{color:var(--accent-fg)}
  .cell{padding:13px 18px;display:flex;align-items:center}
  td.mod .cell{gap:13px}
  td.v .cell{justify-content:flex-start}
  td.n .cell{justify-content:flex-end}
  .badge{flex:none;display:inline-flex;align-items:center;gap:6px;font-family:var(--mono);font-size:11.5px;
    font-weight:500;padding:4px 9px;border-radius:7px;text-transform:lowercase;white-space:nowrap;
    color:var(--prov,var(--accent-fg));
    background:color-mix(in srgb,var(--prov,var(--accent)) 13%,transparent);
    border:1px solid color-mix(in srgb,var(--prov,var(--accent)) 30%,transparent)}
  .badge .dot{width:6px;height:6px;border-radius:50%;background:var(--prov,var(--accent))}
  .mtext{display:flex;flex-direction:column;min-width:0}
  .name{font-family:var(--mono);font-size:14px;font-weight:600;color:var(--fg);letter-spacing:-.01em;transition:color .12s}
  a.name:hover{text-decoration:none}
  .path{font-size:11.5px;color:var(--faint);font-family:var(--mono);margin-top:2px;white-space:nowrap;
    overflow:hidden;text-overflow:ellipsis;max-width:46ch}
  .vpill{font-family:var(--mono);font-size:12.5px;font-weight:500;color:var(--fg-soft);
    background:var(--panel-2);border:1px solid var(--border);border-radius:7px;padding:3px 9px}
  .count{font-family:var(--mono);font-size:13px;color:var(--muted)}
  .empty{color:var(--muted);text-align:center;padding:34px 0;font-size:14px}

  .crumb{display:inline-flex;align-items:center;gap:7px;font-size:13px;color:var(--muted);margin:6px 0 24px;
    padding:6px 13px;border:1px solid var(--border);border-radius:999px;background:var(--panel);transition:.15s}
  .crumb:hover{color:var(--fg);border-color:var(--border-strong);text-decoration:none}
  .badge-line{margin:0 0 12px}
  .title{display:flex;align-items:center;gap:13px;flex-wrap:wrap;margin:0 0 8px}
  .name-lg{font-family:var(--mono);font-size:1.75rem;font-weight:600;letter-spacing:-.025em;color:var(--fg)}
  .host{font-family:var(--mono);font-size:12.5px;color:var(--faint);margin:0}
  .pill{display:inline-flex;align-items:center;gap:6px;padding:3px 11px;border-radius:999px;
    background:var(--accent-soft);border:1px solid color-mix(in srgb,var(--accent) 35%,transparent);
    color:var(--accent-fg);font-family:var(--mono);font-size:11.5px;font-weight:500}
  .vrow{display:flex;align-items:center;justify-content:space-between;gap:14px;padding:13px 18px;border-bottom:1px solid var(--border)}
  .vrow:last-child{border-bottom:none}
  .vrow .ver{font-family:var(--mono);font-size:14px;font-weight:500;color:var(--fg);display:flex;align-items:center;gap:10px}
  .vrow .dl{font-family:var(--sans);font-size:13px;font-weight:500}

  @media (max-width:600px){
    .hero h1{font-size:1.75rem}
    .name-lg{font-size:1.4rem}
    .path{max-width:30ch}
    .wrap{padding:0 16px 72px}
  }
  @media (prefers-reduced-motion:no-preference){
    .reveal{animation:rise .5s cubic-bezier(.2,.7,.2,1) both}
    @keyframes rise{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:none}}
  }
`;

function page(title, inner, script = "") {
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="dark light">
<title>${esc(title)}</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=IBM+Plex+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>${STYLE}</style>
</head>
<body>
<div class="wrap">${inner}</div>
<script>
(function(){
  document.addEventListener("click",function(e){
    var b=e.target.closest(".copy"); if(!b) return;
    var s=b.closest(".snip"), c=s&&s.querySelector("code"); if(!c) return;
    var done=function(){var o=b.textContent;b.textContent="Copied";b.classList.add("ok");
      setTimeout(function(){b.textContent=o;b.classList.remove("ok");},1300);};
    if(navigator.clipboard&&navigator.clipboard.writeText){navigator.clipboard.writeText(c.innerText).then(done,function(){});}
  });
})();
</script>${script}
</body>
</html>`;
}

// Path to a module's human detail page (distinct from the /v1/ protocol routes).
const detailPath = (key) => `/modules/${key}`;

// ns/name/provider -> parts. Catalog keys are always exactly three segments.
function parseKey(key) {
  const [ns, name, provider] = String(key).split("/");
  return { ns, name, provider };
}

// Provider accent colors for the catalog badges - purely cosmetic, falls back to
// the theme accent for anything unrecognised.
const PROVIDER_COLORS = {
  aws: "#ff9900", gcp: "#4285f4", google: "#4285f4", azure: "#3b82f6", azurerm: "#3b82f6",
  github: "#a6accd", gitlab: "#fc6d26", kubernetes: "#3970e4", k8s: "#3970e4", helm: "#3970e4",
  datadog: "#7c5cff", cloudflare: "#f48120", qdrant: "#e5466e", vault: "#facc15",
  docker: "#2496ed", vercel: "#94a3b8", mongodb: "#13aa52", redis: "#ff4438", postgres: "#4169e1",
};
const providerColor = (p) => PROVIDER_COLORS[String(p || "").toLowerCase()] || "var(--accent)";

const SEARCH_ICON =
  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/></svg>';

function landingHtml(idx) {
  const keys = idx ? Object.keys(idx).sort() : [];
  const example =
    idx && idx["c0x12c/rds/aws"]
      ? { key: "c0x12c/rds/aws", v: latestVersion(idx["c0x12c/rds/aws"]) }
      : { key: "c0x12c/<module>/<provider>", v: "x.y.z" };
  const totalVersions = keys.reduce((s, k) => s + idx[k].length, 0);
  const providerCount = new Set(keys.map((k) => parseKey(k).provider)).size;
  const rows = keys
    .map((k) => {
      const { name, provider } = parseKey(k);
      const color = providerColor(provider);
      const latest = esc(latestVersion(idx[k]));
      const count = idx[k].length;
      const href = esc(detailPath(k));
      const src = `${REGISTRY_HOST}/${k}`;
      return `<tr class="link" data-href="${href}">
        <td class="mod"><div class="cell">
          <span class="badge" style="--prov:${color}"><span class="dot"></span>${esc(provider)}</span>
          <span class="mtext"><a class="name" href="${href}">${esc(name)}</a><span class="path">${esc(src)}</span></span>
        </div></td>
        <td class="v"><div class="cell"><span class="vpill">${latest}</span></div></td>
        <td class="n"><div class="cell"><span class="count">${count}</span></div></td>
      </tr>`;
    })
    .join("");
  const catalog = keys.length
    ? `<div class="search-wrap">${SEARCH_ICON}<input id="q" class="search" type="search"
        placeholder="Filter by name or provider…" autocomplete="off" autocapitalize="off"
        spellcheck="false" aria-label="Filter modules"></div>
    <div class="tbl">
      <table>
        <thead><tr><th>Module</th><th>Latest</th><th class="r">Versions</th></tr></thead>
        <tbody id="rows">${rows}</tbody>
      </table>
      <p id="empty" class="empty" hidden>No modules match your filter.</p>
    </div>`
    : `<div class="tbl"><p class="empty">Catalog temporarily unavailable - try again shortly.</p></div>`;
  const snippet = esc(
    `module "example" {\n  source  = "${REGISTRY_HOST}/${example.key}"\n  version = "${example.v}"\n}`
  );
  const inner = `
  <header class="bar">
    <div class="brand"><span class="logo">c0</span> c0x12c Registry</div>
    <span class="tag">modules.v1 · anonymous</span>
  </header>

  <section class="hero reveal">
    <h1>Terraform <span class="accent">module registry</span></h1>
    <p class="lede">Self-hosted, public, anonymous. Reference any module directly in
    <code>terraform init</code> over HTTPS - no login, no token, no setup.</p>
    <div class="stats">
      <div class="stat"><div class="num">${keys.length || "-"}</div><div class="lbl">Modules</div></div>
      <div class="stat"><div class="num">${totalVersions || "-"}</div><div class="lbl">Versions</div></div>
      <div class="stat"><div class="num">${providerCount || "-"}</div><div class="lbl">Providers</div></div>
    </div>
  </section>

  <div class="sec"><h2>Quick start</h2><span class="hint">Paste into any .tf file</span></div>
  <div class="snip"><pre><code>${snippet}</code></pre><button class="copy" type="button">Copy</button></div>
  <p class="note">Service discovery: <a href="/.well-known/terraform.json">/.well-known/terraform.json</a></p>

  <div class="sec"><h2>Modules</h2><span class="hint" id="shown">${keys.length || 0} total</span></div>
  ${catalog}`;
  const script = `<script>
(function () {
  var rows = Array.prototype.slice.call(document.querySelectorAll("#rows tr"));
  rows.forEach(function (r) {
    r.dataset.k = (r.textContent || "").toLowerCase();
    r.addEventListener("click", function (e) {
      if (e.target.closest("a")) return; // let real links handle themselves
      if (r.dataset.href) location.href = r.dataset.href;
    });
  });
  var q = document.getElementById("q");
  if (!q) return;
  var empty = document.getElementById("empty"), shown = document.getElementById("shown"), total = rows.length;
  q.addEventListener("input", function () {
    var term = q.value.trim().toLowerCase(), n = 0;
    rows.forEach(function (r) {
      var hit = !term || r.dataset.k.indexOf(term) !== -1;
      r.hidden = !hit;
      if (hit) n++;
    });
    if (empty) empty.hidden = n !== 0;
    if (shown) shown.textContent = term ? (n + " of " + total) : (total + " total");
  });
})();
</script>`;
  return page("c0x12c Terraform Module Registry", inner, script);
}

// Per-module detail page: pinned-usage snippet for the latest version plus every
// published version with a direct tarball download link.
function moduleDetailHtml(key, versions) {
  const latest = latestVersion(versions);
  // Sort versions for display the same way the catalog picks "latest" (desc).
  const sorted = [...versions].sort((a, b) => {
    const pa = semverParts(a);
    const pb = semverParts(b);
    for (let i = 0; i < 3; i++) {
      if ((pa[i] || 0) !== (pb[i] || 0)) return (pb[i] || 0) - (pa[i] || 0);
    }
    return 0;
  });
  const { name, provider } = parseKey(key);
  const color = providerColor(provider);
  const snippet = esc(
    `module "example" {\n  source  = "${REGISTRY_HOST}/${key}"\n  version = "${latest}"\n}`
  );
  const rows = sorted
    .map((v) => {
      const dl = `/v1/modules/${esc(key)}/${esc(v)}/archive.tar.gz`;
      const tag = v === latest ? ' <span class="pill">latest</span>' : "";
      return `<div class="vrow"><span class="ver"><code>${esc(v)}</code>${tag}</span><a class="dl" href="${dl}">Download .tar.gz ↓</a></div>`;
    })
    .join("");
  const inner = `
  <header class="bar">
    <div class="brand"><span class="logo">c0</span> c0x12c Registry</div>
    <span class="tag">modules.v1 · anonymous</span>
  </header>

  <a class="crumb" href="/">← All modules</a>

  <section class="reveal">
    <p class="badge-line"><span class="badge" style="--prov:${color}"><span class="dot"></span>${esc(provider)}</span></p>
    <div class="title"><span class="name-lg">${esc(name)}</span><span class="pill">v${esc(latest)} latest</span></div>
    <p class="host">${esc(REGISTRY_HOST)}/${esc(key)}</p>
  </section>

  <div class="sec"><h2>Quick start</h2><span class="hint">Pinned to latest</span></div>
  <div class="snip"><pre><code>${snippet}</code></pre><button class="copy" type="button">Copy</button></div>
  <p class="note">Pin <code>version</code> to any release below. <code>terraform init</code> resolves it over HTTPS - no auth.</p>

  <div class="sec"><h2>Versions</h2><span class="hint">${versions.length} release${versions.length === 1 ? "" : "s"}</span></div>
  <div class="tbl">${rows}</div>`;
  return page(`${name}/${provider} - c0x12c Registry`, inner);
}

function notFoundHtml() {
  const inner = `
  <header class="bar">
    <div class="brand"><span class="logo">c0</span> c0x12c Registry</div>
    <span class="tag">modules.v1 · anonymous</span>
  </header>

  <section class="hero reveal">
    <h1>404 <span class="accent">- not found</span></h1>
    <p class="lede">This is the c0x12c self-hosted Terraform module registry.
    That path isn't a registry endpoint.</p>
  </section>

  <div class="sec"><h2>Use a module</h2></div>
  <div class="snip"><pre><code>source  = &quot;${esc(REGISTRY_HOST)}/c0x12c/&lt;module&gt;/&lt;provider&gt;&quot;</code></pre></div>
  <p class="note"><a href="/">← Browse the module catalog</a></p>`;
  return page("Not found", inner);
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

      // Human module detail page (not part of the protocol). Best-effort like /.
      let dm = p.match(/^\/modules\/([^/]+)\/([^/]+)\/([^/]+)$/);
      if (dm) {
        const key = `${dm[1]}/${dm[2]}/${dm[3]}`;
        let idx = null;
        try {
          idx = await loadIndex(env);
        } catch (e) {
          idx = null;
        }
        const versions = idx && idx[key];
        if (!versions) {
          return new Response(notFoundHtml(), {
            status: 404,
            headers: { "content-type": "text/html; charset=utf-8" },
          });
        }
        return new Response(moduleDetailHtml(key, versions), {
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
