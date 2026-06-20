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

// Thousands-separated count for display.
const fmtNum = (n) => Number(n || 0).toLocaleString("en-US");

// --- Download stats (D1) ---------------------------------------------------
// Best-effort, exactly like the R2 path: a missing `DB` binding or any query
// error degrades to zero counts and NEVER throws, so download serving and page
// rendering are unaffected. The binding is added in a follow-up once the D1
// database is provisioned (see schema.sql); until then env.DB is undefined and
// every counter reads 0.

// Fire-and-forget atomic increment on a real tarball delivery. Wrapped in
// ctx.waitUntil so it never delays the response, and `.catch` so a stats-write
// failure can't surface as a 5xx on the download.
function bumpDownload(env, ctx, key, version) {
  if (!env.DB || !ctx) return;
  const work = env.DB.prepare(
    "INSERT INTO downloads (module_key, version, count, last_at) VALUES (?, ?, 1, datetime('now')) ON CONFLICT(module_key, version) DO UPDATE SET count = count + 1, last_at = datetime('now')"
  )
    .bind(key, version)
    .run()
    .catch(() => {});
  ctx.waitUntil(work);
}

// Per-module totals across the whole registry: { "ns/name/provider": total }.
// Cached like INDEX_CACHE: the landing page is hit by crawlers/monitors on every
// "/" load, and an aggregate that's 60s stale is fine for an approximate counter.
// Without this, every "/" would run a full-table GROUP BY against D1.
let TOTALS_CACHE = null; // { data, ts }
const TOTALS_TTL_MS = 60_000;
async function dlTotals(env) {
  if (!env.DB) return {};
  const now = Date.now();
  if (TOTALS_CACHE && now - TOTALS_CACHE.ts < TOTALS_TTL_MS) return TOTALS_CACHE.data;
  try {
    const { results } = await env.DB.prepare(
      "SELECT module_key, SUM(count) AS total FROM downloads GROUP BY module_key"
    ).all();
    const out = {};
    for (const r of results || []) out[r.module_key] = Number(r.total) || 0;
    TOTALS_CACHE = { data: out, ts: now };
    return out;
  } catch (e) {
    return {};
  }
}

// Per-version counts for one module: { "0.6.5": 12, ... }.
async function dlByVersion(env, key) {
  if (!env.DB) return {};
  try {
    const { results } = await env.DB.prepare(
      "SELECT version, count FROM downloads WHERE module_key = ?"
    )
      .bind(key)
      .all();
    const out = {};
    for (const r of results || []) out[r.version] = Number(r.count) || 0;
    return out;
  } catch (e) {
    return {};
  }
}

// Count for one (module, version).
async function dlOne(env, key, version) {
  if (!env.DB) return 0;
  try {
    const row = await env.DB.prepare(
      "SELECT count FROM downloads WHERE module_key = ? AND version = ?"
    )
      .bind(key, version)
      .first();
    return (row && Number(row.count)) || 0;
  } catch (e) {
    return 0;
  }
}

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
  .brand{display:inline-flex;align-items:center;gap:11px;font-weight:600;letter-spacing:-.01em;
    font-size:15px;color:var(--fg);text-decoration:none;transition:opacity .15s ease;border-radius:8px}
  .brand:hover{text-decoration:none;opacity:.72}
  .brand:focus-visible{outline:2px solid var(--accent-fg);outline-offset:3px}
  .logo{display:block;width:30px;height:30px;flex:none}
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
  .chips{display:flex;flex-wrap:wrap;gap:8px;margin:0 0 14px}
  .chip{display:inline-flex;align-items:center;gap:7px;font:inherit;font-size:12.5px;color:var(--fg-soft);
    background:var(--panel);border:1px solid var(--border);border-radius:999px;padding:6px 13px;cursor:pointer;
    transition:.12s;-webkit-tap-highlight-color:transparent}
  .chip .dot{width:7px;height:7px;border-radius:50%;background:var(--prov,var(--accent));flex:none}
  .chip .chip-n{font-family:var(--mono);font-size:11px;color:var(--faint)}
  .chip:hover:not(.on){border-color:var(--border-strong);color:var(--fg)}
  .chip.on{background:var(--accent-soft);color:var(--accent-fg);
    border-color:color-mix(in srgb,var(--accent) 40%,transparent)}
  .chip.on .chip-n{color:var(--accent-fg)}
  .chip:focus-visible{outline:2px solid var(--accent-fg);outline-offset:2px}

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
  thead th a.sort{display:inline-flex;align-items:center;gap:5px;color:inherit;text-transform:inherit;
    letter-spacing:inherit;font-weight:inherit;transition:color .12s}
  thead th a.sort:hover{color:var(--fg);text-decoration:none}
  thead th a.sort.on{color:var(--fg)}
  thead th a.sort .arr{font-size:9px;line-height:1;opacity:.85}
  th.r a.sort{flex-direction:row-reverse}
  th.pcol{width:1%;white-space:nowrap}
  td.prov .cell{padding-right:6px}
  td.prov .badge{white-space:nowrap}
  td.mod .cell{gap:0}
  .pager{display:flex;align-items:center;justify-content:space-between;gap:12px 16px;flex-wrap:wrap;
    padding:16px 6px 4px}
  .prange{font-family:var(--mono);font-size:12px;color:var(--muted)}
  .pgrp{display:flex;align-items:center;gap:4px;margin-left:auto}
  .pg{min-width:36px;height:36px;display:inline-flex;align-items:center;justify-content:center;
    font:inherit;font-size:13px;font-variant-numeric:tabular-nums;color:var(--fg-soft);background:var(--panel);
    border:1px solid var(--border);border-radius:9px;padding:0 6px;cursor:pointer;transition:.12s;
    -webkit-tap-highlight-color:transparent}
  .pg svg{width:16px;height:16px}
  .pg:hover:not(:disabled):not(.on){border-color:var(--border-strong);color:var(--fg);background:var(--panel-2)}
  .pg.on{background:var(--accent-soft);color:var(--accent-fg);font-weight:600;cursor:default;
    border-color:color-mix(in srgb,var(--accent) 45%,transparent)}
  .pg:disabled{opacity:.36;cursor:default}
  .pg:focus-visible{outline:2px solid var(--accent-fg);outline-offset:2px}
  .pgdots{min-width:22px;text-align:center;color:var(--faint);user-select:none}

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
  .vrow .vlink{color:var(--fg)}
  .vrow .vlink:hover{color:var(--accent-fg);text-decoration:none}
  .vrow .vlink:hover code{text-decoration:underline}
  .vacts{display:flex;align-items:center;gap:16px}
  .vrow .rn{font-family:var(--sans);font-size:13px;font-weight:500}
  .vrow .dl{font-family:var(--mono);font-size:12.5px;color:var(--muted)}
  .vrow .dl:hover{color:var(--fg)}
  .dlc{font-family:var(--mono);font-size:12.5px;color:var(--faint);white-space:nowrap}

  .changelog{background:var(--panel);border:1px solid var(--border);border-radius:14px;
    padding:6px 22px 20px;box-shadow:var(--shadow)}
  .changelog .cl-h{letter-spacing:-.01em}
  .changelog h2.cl-h{font-size:1.15rem;font-weight:600;margin:22px 0 4px;color:var(--fg)}
  .changelog h2.cl-h a{color:var(--fg)}
  .changelog h3.cl-h{font-size:.74rem;text-transform:uppercase;letter-spacing:.12em;
    color:var(--accent-fg);font-weight:600;margin:20px 0 8px}
  .changelog h4.cl-h{font-size:.95rem;font-weight:600;margin:16px 0 6px;color:var(--fg-soft)}
  .changelog p{color:var(--fg-soft);margin:10px 0}
  .changelog .cl-ul{margin:8px 0;padding-left:22px}
  .changelog .cl-ul li{margin:6px 0;color:var(--fg-soft)}
  .changelog .cl-ul .cl-ul{margin:4px 0}
  .changelog code{font-family:var(--mono);font-size:.86em;background:var(--panel-2);
    border:1px solid var(--border);border-radius:5px;padding:1px 5px}
  .changelog .cl-pre{margin:12px 0;background:var(--panel-2);border:1px solid var(--border);
    border-radius:10px;padding:14px 16px;overflow:auto}
  .changelog .cl-pre code{background:none;border:none;padding:0;font-size:12.5px;line-height:1.7;color:var(--fg-soft)}

  @media (max-width:600px){
    .vrow{flex-direction:column;align-items:flex-start;gap:9px}
  }

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

const BRAND = `<a class="brand" href="/" aria-label="c0x12c Registry - home"><picture class="logo"><source srcset="data:image/webp;base64,UklGRj4EAABXRUJQVlA4WAoAAAAQAAAASAAASgAAQUxQSKMDAAABkChJsmlb++LZtm3btm3btm3btm3btm0bl7vWrLk/EBESHElSJMkrlg69pCj6giMcWX742I5Hfb0cpdHEx37M1MKZo5BmWoQ4bc/vPFqJ/8Y+z2Nppchf+xwNppV+Cn9mrBYe6xVSXysR79rzNa1WMnwnXrVs7h73yeZ2RK3Uxln3o3l9I5stnlqZTvwrDTZ1cF4DtAh2lFTfJxHOq4xW4r4i10uhYV5HyOZDUq0U+kOuS8Em5nOyuRxGKz19aLQCmzy/yWaF2npYgxtEXtDpgvPqpJVw10n1RWzQWUX8KaiVlJ/J9VgwN2Gv4iqJq5VaPjSGg02KTzgvT61MIn4lAptK/0mnntp6OEuqbUhnArHOCYJDaCiRkDiuRkeiKZGWWK52BN0GvkUi5hOlBLVPnsU1MiH9ybQv2eShP3LAw0i6y+A0h0hCB/6tEID3JapQavOm/sTHzdsoxHb6WoxsOpHNCMfINHJqQjZVhPtCzI90AwlrvrPQEXqKlkjoB8DnOI5sjVcwfnie9HHzNyPpjCbTjmRTjGx2OEbakNN4sknzm7bOYFTEm8D3xEZivKddKgL1cL+Pm/+5SXIATbaP+eticqpBNg18rIt4O4SRfFTrPWQTgQ6Fd9GIrTStkoE/hLVOKTxQm2IRrRZ3D3IaLCziaXERjcT7AjwMIyxiJmERO5i/4tWprLCIE6RF9DZSgkzXqxbxXy7jR6h7tM8lJJbQtGoKizjbMTKYnHroFjGqkaRU62vBqIiXpUUU7EzCfa6w8LIxRLwzGalBpouFRXwURrozme8UT4FPsYgNNK1y4p3JyHjhoVuSbDaIi2gkLdX6rJewiInsdiaq9TGqdTbSGUKmPcmmABVxp2OkMZnOIJvkP6mIwenqcc3HzcloRiK9octVJGIXbccFsUDNXaNxXg/z1270tTnZZCab1Y7W2EPEFG6KddQ4QRQUrvnBaszgd4BsC/+SSu2C+1u27Qe7RTa3wgfF+7Qd2OTFea1Uewesw3dAftDpgPPqoPYOuEGqL+ksWojzyqeVdF/xLhscFvl5fGfECop3wETarj+QzQFvrUzGNACbsv/wKqhFsMPE90yyned/Za3EfEaudyLCdo5nyOeUWsn9S/Zgj3QP36ehtdIJ/8ys5u4xA20WOlpjkY/9aKFFmCv2/MymlWQf7fMoqlbK/7fPHi+tDFf4MwO08Nxhz79SWol83z7vE2kl2zf7nA6hleyHflpnhhQHAFZQOCB0AAAAkAcAnQEqSQBLAD4pEIZCIaEMKgAMAUJaQAV4B/APwA/QCn/RnA/lwtNzN33VVUTnXHXuvyuKKv7gfpqJtxPvIOLkPMMAAP7+0E43M4hv1L///yW///kz7//8lwcvU6JH/3Z7o9VLb1UEXfVQXXvEoAAAAAA=" media="(prefers-color-scheme:dark)"><img src="data:image/webp;base64,UklGRuYDAABXRUJQVlA4WAoAAAAQAAAASgAASgAAQUxQSI4DAAABoC3Jtmnbmse2bdu2bdu2bdu2bdu2bdu+62nV7aPtH4gIB27bOJLjQy8KztPuCZ61sv7wudajvkE8WTX1udcMnby5AjfVKeQZd/3MrnP8N+5+HF3non/dvT+ozv0FrxmjU6ANAtfQOdJdd31Nq3PG76RXLZv71wOiuR1B5zrYeT+gyfCNaLYE1nkG6V9poKmLnfXXKdhRgn2fxNhZGZ3jvSbaS6GhsyPYWVKdC+EIWQo0sZ4TzeUwOvfyUbUCmoJ/iGa5cISsJf3OCzhdsbOOOoe7TrDPY0Fnq0h/Cuic9ivRHg3mTxP2KtG8jKtzbR/VMKBJ8Qk7C6zzZJxpEwJNpf8Ip65whJwl2NaEM4G01guQ5WoIKRHpmFAdSU1I6UjLhIvVHZoaI5IWkEqaBkLyLH6VCTWAWPsQTV56yf5ABqW/AlRzSElok3AzBCjoZaD5lcoy9T8FqrdRSNvpuijRdCGa4aYZ1virVjHOGLE+0c7FMidlpYnsFA2b0LSGfI5DWkONlTdcAp8CqL8ZCWcMsXYgmuJEs93yWFuiGk80aX7T5ErbgBA3Qd8TGRTjA+hFBErlAVo+chHkQGq3t+V6iXG1b0g0s42xvB3CoHwU9D0Yy1egd1FJW6mxIoZL8GsU9JTusazqOOh7EtVgQSwfgj7FtqyzX0APw0hj2d5yjRuvsuJYGlSSWNerY/n/CnUP9C2hMZbVjbGcZXlsKFH1MMZytzGWb6MalOwn6Fow4zyYwhjLxpbrHURV2BjLQcZYHrVM2bWIdbE1lqFtsfyT0bIXeUpBjyWN5TjLYxOJqo0xlutcY4mLKO3QzgbRxtIyZR+noGcjnCHE2p1oClIsd5i2DsajZXKK5dVgtlnrRDSDIr+lw0Uk0i6g+a8Ahqm5XzXOG8hy3YOumxNNZqJZ6elqDymmcVTUFuoEqaDx1YOFmsEnC9tE/yWlTimN+/7gt4nmZviAOQO3o3ntN9GsEJ4s1uPJIp9te+lrr3PEOwT7gtatRXx20TkdniyOB4fBfx47i6VzLR/VRKBJ+iFg/n6Ygq4PNOX+4XZSeLI4TPqeybZo/VdZ55jPiPZORJj3cO/7IYnOuX/Z/hyIdI/HoM6d8DUzm/vXDKRZ4Olqsc+9musU5orgj7KsOif76O5HUXUu/5+79wTRebjgNf11CrzDXf9K6Rz5vrvfJdI52zd3nwqhc/ZDP5093SwPVlA4IDIAAADwAwCdASpLAEsAPikUiUMhoSEQpAAYAoS0gAAE+NGjRo0aNGjRoz8AAP7+0BwAAAAAAA==" alt="Spartan" width="30" height="30"></picture> c0x12c Registry</a>`;

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
// Path to a single version's release-notes page.
const versionPath = (key, v) => `/modules/${key}/${v}`;

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

function landingHtml(idx, totals = {}, sort = "name", order = "asc") {
  // Backend-side sort of the catalog. Name uses the module name (then full key
  // as a stable tiebreak); pulls uses the download total, tiebroken by name.
  const cmpName = (a, b) =>
    parseKey(a).name.localeCompare(parseKey(b).name) || a.localeCompare(b);
  const keys = idx
    ? Object.keys(idx).sort((a, b) => {
        let c =
          sort === "pulls"
            ? Number(totals[a] || 0) - Number(totals[b] || 0)
            : cmpName(a, b);
        if (c === 0) c = cmpName(a, b);
        return order === "desc" ? -c : c;
      })
    : [];
  const example =
    idx && idx["c0x12c/rds/aws"]
      ? { key: "c0x12c/rds/aws", v: latestVersion(idx["c0x12c/rds/aws"]) }
      : { key: "c0x12c/<module>/<provider>", v: "x.y.z" };
  const totalVersions = keys.reduce((s, k) => s + idx[k].length, 0);
  const providerCount = new Set(keys.map((k) => parseKey(k).provider)).size;
  const grandDownloads = Object.values(totals).reduce((s, n) => s + Number(n || 0), 0);
  const provCounts = {};
  keys.forEach((k) => {
    const pr = parseKey(k).provider;
    provCounts[pr] = (provCounts[pr] || 0) + 1;
  });
  const provList = Object.keys(provCounts).sort();
  const rows = keys
    .map((k) => {
      const { name, provider } = parseKey(k);
      const color = providerColor(provider);
      const latest = esc(latestVersion(idx[k]));
      const count = idx[k].length;
      const href = esc(detailPath(k));
      const src = `${REGISTRY_HOST}/${k}`;
      return `<tr class="link" data-href="${href}" data-prov="${esc(provider)}">
        <td class="prov"><div class="cell"><span class="badge" style="--prov:${color}"><span class="dot"></span>${esc(provider)}</span></div></td>
        <td class="mod"><div class="cell"><span class="mtext"><a class="name" href="${href}">${esc(name)}</a><span class="path">${esc(src)}</span></span></div></td>
        <td class="v"><div class="cell"><span class="vpill">${latest}</span></div></td>
        <td class="n"><div class="cell"><span class="count">${count}</span></div></td>
        <td class="n"><div class="cell"><span class="count dlc">${fmtNum(totals[k] || 0)}</span></div></td>
      </tr>`;
    })
    .join("");
  // Header sort links. Non-active column opens with a sensible first order
  // (name asc, pulls desc); clicking the active column flips the order.
  const firstOrder = (col) => (col === "pulls" ? "desc" : "asc");
  const nextOrder = (col) =>
    sort === col ? (order === "asc" ? "desc" : "asc") : firstOrder(col);
  const sortTh = (col, label, extra = "") => {
    const on = sort === col;
    const arr = on ? `<span class="arr">${order === "asc" ? "▲" : "▼"}</span>` : "";
    return `<a class="sort${on ? " on" : ""}" href="/?sort=${col}&order=${nextOrder(col)}"${extra}>${label}${arr}</a>`;
  };
  const pullsTitle = ' title="Cold terraform init fetches (CI-inflated), not unique adopters"';
  const catalog = keys.length
    ? `<div class="search-wrap">${SEARCH_ICON}<input id="q" class="search" type="search"
        placeholder="Filter by name or provider…" autocomplete="off" autocapitalize="off"
        spellcheck="false" aria-label="Filter modules"></div>
    <div class="chips" id="chips" role="group" aria-label="Filter by provider">
      <button type="button" class="chip on" data-prov="" aria-pressed="true">All <span class="chip-n">${keys.length}</span></button>
      ${provList
        .map(
          (pr) =>
            `<button type="button" class="chip" data-prov="${esc(pr)}" aria-pressed="false" style="--prov:${providerColor(pr)}"><span class="dot"></span>${esc(pr)} <span class="chip-n">${provCounts[pr]}</span></button>`
        )
        .join("")}
    </div>
    <div class="tbl">
      <table>
        <thead><tr><th class="pcol">Provider</th><th>${sortTh("name", "Module")}</th><th>Latest</th><th class="r">Versions</th><th class="r">${sortTh("pulls", "Pulls", pullsTitle)}</th></tr></thead>
        <tbody id="rows">${rows}</tbody>
      </table>
      <p id="empty" class="empty" hidden>No modules match your filter.</p>
      <nav class="pager" id="pager" aria-label="Module list pagination" hidden>
        <span class="prange" id="prange"></span>
        <div class="pgrp" id="pgrp"></div>
      </nav>
    </div>`
    : `<div class="tbl"><p class="empty">Catalog temporarily unavailable - try again shortly.</p></div>`;
  const snippet = esc(
    `module "example" {\n  source  = "${REGISTRY_HOST}/${example.key}"\n  version = "${example.v}"\n}`
  );
  const inner = `
  <header class="bar">
    ${BRAND}
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
      <div class="stat"><div class="num">${grandDownloads ? fmtNum(grandDownloads) : "-"}</div><div class="lbl">Pulls</div></div>
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
  var chips = document.getElementById("chips"), activeProv = "";
  var empty = document.getElementById("empty"), shown = document.getElementById("shown"), total = rows.length;
  var pager = document.getElementById("pager"), pgrp = document.getElementById("pgrp"), prange = document.getElementById("prange");
  var PAGE = 25, page = 0;
  var CH_L = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m15 18-6-6 6-6"/></svg>';
  var CH_R = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>';

  // Page numbers with first/last anchors and ellipsis around the current page.
  function pageItems(cur, total) {
    var range = [1], out = [], last;
    for (var i = cur - 1; i <= cur + 1; i++) if (i > 1 && i < total) range.push(i);
    if (total > 1) range.push(total);
    range = range.filter(function (v, i, a) { return a.indexOf(v) === i; }).sort(function (a, b) { return a - b; });
    range.forEach(function (n) {
      if (last) { if (n - last === 2) out.push(last + 1); else if (n - last > 2) out.push("..."); }
      out.push(n); last = n;
    });
    return out;
  }
  function navBtn(act, disabled, icon, label) {
    return '<button type="button" class="pg" data-act="' + act + '"' + (disabled ? " disabled" : "") +
      ' aria-label="' + label + '">' + icon + "</button>";
  }
  function renderPager(count, pages) {
    if (!pager) return;
    pager.hidden = pages <= 1;
    if (pages <= 1) return;
    var from = page * PAGE + 1, to = Math.min(count, (page + 1) * PAGE);
    if (prange) prange.textContent = from + "-" + to + " of " + count;
    var html = navBtn("prev", page === 0, CH_L, "Previous page");
    pageItems(page + 1, pages).forEach(function (it) {
      if (it === "...") { html += '<span class="pgdots" aria-hidden="true">…</span>'; return; }
      var on = it === page + 1;
      html += '<button type="button" class="pg' + (on ? " on" : "") + '" data-page="' + it + '"' +
        (on ? ' aria-current="page"' : "") + ' aria-label="Page ' + it + '">' + it + "</button>";
    });
    html += navBtn("next", page >= pages - 1, CH_R, "Next page");
    pgrp.innerHTML = html;
  }

  function apply() {
    var term = q ? q.value.trim().toLowerCase() : "";
    var filtered = rows.filter(function (r) {
      return (!term || r.dataset.k.indexOf(term) !== -1) &&
        (!activeProv || r.dataset.prov === activeProv);
    });
    var pages = Math.max(1, Math.ceil(filtered.length / PAGE));
    if (page > pages - 1) page = pages - 1;
    if (page < 0) page = 0;
    var start = page * PAGE, end = start + PAGE;
    rows.forEach(function (r) { r.hidden = true; });
    filtered.forEach(function (r, i) { if (i >= start && i < end) r.hidden = false; });
    if (empty) empty.hidden = filtered.length !== 0;
    if (shown) shown.textContent = (term || activeProv) ? (filtered.length + " of " + total) : (total + " total");
    renderPager(filtered.length, pages);
  }

  if (pager) {
    pager.addEventListener("click", function (e) {
      var b = e.target.closest("button");
      if (!b || b.disabled) return;
      if (b.dataset.act) page += b.dataset.act === "next" ? 1 : -1;
      else if (b.dataset.page) page = parseInt(b.dataset.page, 10) - 1;
      else return;
      apply();
      var top = document.getElementById("rows");
      if (top) top.scrollIntoView({ block: "nearest" });
    });
  }
  if (q) q.addEventListener("input", function () { page = 0; apply(); });
  if (chips) {
    chips.addEventListener("click", function (e) {
      var c = e.target.closest(".chip");
      if (!c) return;
      activeProv = c.dataset.prov || "";
      Array.prototype.forEach.call(chips.querySelectorAll(".chip"), function (x) {
        var on = x === c;
        x.classList.toggle("on", on);
        x.setAttribute("aria-pressed", on ? "true" : "false");
      });
      page = 0;
      apply();
    });
  }
  apply();
})();
</script>`;
  return page("c0x12c Terraform Module Registry", inner, script);
}

// Per-module detail page: pinned-usage snippet for the latest version plus every
// published version with a direct tarball download link.
function moduleDetailHtml(key, versions, counts = {}) {
  const latest = latestVersion(versions);
  const totalDownloads = Object.values(counts).reduce((s, n) => s + Number(n || 0), 0);
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
      const notes = esc(versionPath(key, v));
      const tag = v === latest ? ' <span class="pill">latest</span>' : "";
      return `<div class="vrow"><span class="ver"><a class="vlink" href="${notes}"><code>${esc(v)}</code></a>${tag}</span><span class="vacts"><span class="dlc" title="pulls (cold terraform init fetches)">${fmtNum(counts[v] || 0)} ↓</span><a class="rn" href="${notes}">Release notes →</a><a class="dl" href="${dl}">.tar.gz ↓</a></span></div>`;
    })
    .join("");
  const inner = `
  <header class="bar">
    ${BRAND}
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

  <div class="sec"><h2>Versions</h2><span class="hint">${versions.length} release${versions.length === 1 ? "" : "s"} · ${fmtNum(totalDownloads)} pulls</span></div>
  <div class="tbl">${rows}</div>`;
  return page(`${name}/${provider} - c0x12c Registry`, inner);
}

// --- Changelog markdown rendering -----------------------------------------
// The release-notes section is stored in R2 as raw markdown (split out of each
// module's CHANGELOG.md by the Python release pipeline). It is team-authored,
// trusted content, but we still HTML-escape every text node defensively. This
// is a deliberately small renderer covering exactly the conventional-changelog
// shapes that appear in the real files: ##/### headings, * bullets (one nested
// level), `inline code`, **bold**, [links](url), and ```fenced``` blocks.
function mdInline(s) {
  s = esc(s);
  s = s.replace(/`([^`]+)`/g, (_m, c) => `<code>${c}</code>`);
  // Drop the empty-link form the changelog generator emits: `[1.4.2]()` -> `1.4.2`.
  s = s.replace(/\[([^\]]+)\]\(\)/g, (_m, t) => t);
  s = s.replace(/\[([^\]]+)\]\(([^)\s]+)\)/g,
    (_m, t, u) => `<a href="${u}" rel="noopener noreferrer" target="_blank">${t}</a>`);
  s = s.replace(/\*\*([^*]+)\*\*/g, (_m, b) => `<strong>${b}</strong>`);
  return s;
}

function renderChangelog(md) {
  const lines = String(md).replace(/\r\n/g, "\n").split("\n");
  const out = [];
  let depth = 0; // open <ul> nesting depth (0, 1, or 2)
  let para = [];
  const flushPara = () => {
    if (para.length) {
      out.push(`<p>${mdInline(para.join(" "))}</p>`);
      para = [];
    }
  };
  const closeLists = (to) => {
    while (depth > to) {
      out.push("</li></ul>");
      depth--;
    }
  };
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const fence = line.match(/^```(\w*)\s*$/);
    if (fence) {
      flushPara();
      closeLists(0);
      const buf = [];
      i++;
      while (i < lines.length && !/^```\s*$/.test(lines[i])) buf.push(lines[i++]);
      out.push(`<pre class="cl-pre"><code>${esc(buf.join("\n"))}</code></pre>`);
      continue;
    }
    let m = line.match(/^(#{2,4})\s+(.*)$/);
    if (m) {
      flushPara();
      closeLists(0);
      const lvl = m[1].length;
      out.push(`<h${lvl} class="cl-h">${mdInline(m[2].trim())}</h${lvl}>`);
      continue;
    }
    m = line.match(/^(\s*)[*-]\s+(.*)$/);
    if (m) {
      flushPara();
      const indent = m[1].replace(/\t/g, "  ").length;
      const want = indent >= 2 ? 2 : 1;
      if (want > depth) {
        while (depth < want) {
          out.push("<ul class=\"cl-ul\">");
          depth++;
        }
      } else {
        closeLists(want);
        out.push("</li>");
      }
      out.push(`<li>${mdInline(m[2].trim())}`);
      continue;
    }
    if (line.trim() === "") {
      flushPara();
      continue;
    }
    // Non-blank, non-bullet line while a list item is open = wrapped
    // continuation of that bullet (the real changelogs wrap long bullets).
    if (depth > 0) {
      out[out.length - 1] += " " + mdInline(line.trim());
      continue;
    }
    para.push(line.trim());
  }
  flushPara();
  closeLists(0);
  return out.join("\n");
}

// Per-version release-notes page. `body` is the raw markdown section for this
// version (null when none was recorded - e.g. a version published before the
// changelog pipeline, or with no CHANGELOG entry).
function versionDetailHtml(key, version, body, count = 0) {
  const { name, provider } = parseKey(key);
  const color = providerColor(provider);
  const dl = `/v1/modules/${esc(key)}/${esc(version)}/archive.tar.gz`;
  const snippet = esc(
    `module "example" {\n  source  = "${REGISTRY_HOST}/${key}"\n  version = "${version}"\n}`
  );
  const notes = body
    ? `<div class="changelog reveal">${renderChangelog(body)}</div>`
    : `<div class="tbl"><p class="empty">No release notes were recorded for this version.</p></div>`;
  const inner = `
  <header class="bar">
    ${BRAND}
    <span class="tag">modules.v1 · anonymous</span>
  </header>

  <a class="crumb" href="${esc(detailPath(key))}">← ${esc(name)}/${esc(provider)}</a>

  <section class="reveal">
    <p class="badge-line"><span class="badge" style="--prov:${color}"><span class="dot"></span>${esc(provider)}</span></p>
    <div class="title"><span class="name-lg">${esc(name)}</span><span class="pill">v${esc(version)}</span></div>
    <p class="host">${esc(REGISTRY_HOST)}/${esc(key)}</p>
  </section>

  <div class="sec"><h2>Install</h2><span class="hint">Pinned to v${esc(version)}</span></div>
  <div class="snip"><pre><code>${snippet}</code></pre><button class="copy" type="button">Copy</button></div>
  <p class="note"><a class="dl" href="${dl}">Download .tar.gz ↓</a> <span class="dlc" title="Cold terraform init fetches (CI-inflated)">${fmtNum(count)} pulls</span></p>

  <div class="sec"><h2>Release notes</h2><span class="hint">v${esc(version)}</span></div>
  ${notes}`;
  return page(`${name}/${provider} v${version} - c0x12c Registry`, inner);
}

function notFoundHtml() {
  const inner = `
  <header class="bar">
    ${BRAND}
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
  async fetch(req, env, ctx) {
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
        const totals = await dlTotals(env);
        const sort = url.searchParams.get("sort") === "pulls" ? "pulls" : "name";
        const order = url.searchParams.get("order") === "desc" ? "desc" : "asc";
        return new Response(landingHtml(idx, totals, sort, order), {
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
        const counts = await dlByVersion(env, key);
        return new Response(moduleDetailHtml(key, versions, counts), {
          headers: { "content-type": "text/html; charset=utf-8" },
        });
      }

      // Per-version release-notes page (4 segments). Best-effort like /.
      let vm = p.match(/^\/modules\/([^/]+)\/([^/]+)\/([^/]+)\/([^/]+)$/);
      if (vm) {
        const key = `${vm[1]}/${vm[2]}/${vm[3]}`;
        const version = vm[4].replace(/^v/, "");
        let idx = null;
        try {
          idx = await loadIndex(env);
        } catch (e) {
          idx = null;
        }
        const versions = idx && idx[key];
        // Unknown module or version that was never published -> real 404.
        if (!versions || !versions.includes(version)) {
          return new Response(notFoundHtml(), {
            status: 404,
            headers: { "content-type": "text/html; charset=utf-8" },
          });
        }
        // Released version with no recorded notes still renders (with fallback).
        let body = null;
        try {
          const obj = await r2Get(env, `modules/${key}/${version}.changelog.md`);
          if (obj) body = await obj.text();
        } catch (e) {
          body = null;
        }
        const dls = await dlOne(env, key, version);
        return new Response(versionDetailHtml(key, version, body, dls), {
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
        // Count this real delivery (both terraform CLI and browser/curl hit here).
        bumpDownload(env, ctx, `${m[1]}/${m[2]}/${m[3]}`, m[4]);
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
