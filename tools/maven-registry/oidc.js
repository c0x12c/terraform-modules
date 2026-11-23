const ISSUER = "https://token.actions.githubusercontent.com";
let cache, lastFetchAttempt, pending;
export function resetOidcState() { cache = undefined; lastFetchAttempt = undefined; pending = undefined; }
const fail = (reason) => ({ ok: false, reason });
function decode(segment) {
  if (!/^[A-Za-z0-9_-]+$/.test(segment) || segment.length % 4 === 1) throw new Error();
  const bytes = Uint8Array.from(atob(segment.replace(/-/g, "+").replace(/_/g, "/")), (c) => c.charCodeAt(0));
  return bytes;
}
export async function verifyGithubOidc(jwt, opts) {
  try {
    const { audience, allowedOwners, allowedRepos = [], fetchImpl = globalThis.fetch, now = Date.now } = opts;
    if (typeof audience !== "string" || !audience || !Array.isArray(allowedOwners) ||
        !Array.isArray(allowedRepos)) return fail("invalid_options");
    if (!allowedRepos.length) return fail("repos_not_configured");
    if (typeof jwt !== "string" || jwt.split(".").length !== 3) return fail("malformed_token");
    const parts = jwt.split(".");
    let header, claims, signature;
    try {
      const decoder = new TextDecoder("utf-8", { fatal: true });
      header = JSON.parse(decoder.decode(decode(parts[0])));
      claims = JSON.parse(decoder.decode(decode(parts[1])));
      signature = decode(parts[2]);
      if (!header || !claims || typeof header !== "object" || typeof claims !== "object") throw new Error();
    } catch { return fail("invalid_encoding"); }
    if (header.alg !== "RS256") return fail(header.alg === "none" ? "alg_none" : "unsupported_alg");
    if (typeof header.kid !== "string" || !header.kid) return fail("unknown_kid");
    const time = now();
    if (!Number.isFinite(time)) return fail("invalid_options");
    let keys;
    try {
      const load = async () => {
        if (pending) return pending;
        if (lastFetchAttempt !== undefined && time - lastFetchAttempt < 60_000) {
          if (!cache) throw new Error();
          return cache.keys;
        }
        lastFetchAttempt = time;
        pending = (async () => {
          const response = await fetchImpl(`${ISSUER}/.well-known/jwks`);
          if (!response.ok) throw new Error();
          const jwks = await response.json();
          if (!Array.isArray(jwks.keys)) throw new Error();
          cache = { keys: jwks.keys, time };
          return cache.keys;
        })();
        try { return await pending; } finally { pending = undefined; }
      };
      keys = cache && time >= cache.time && time - cache.time < 600_000 ? cache.keys : await load();
      if (!keys.some((key) => key?.kid === header.kid)) keys = await load();
    } catch { return fail("jwks_unavailable"); }
    const jwk = keys.find((key) => key?.kid === header.kid);
    if (!jwk) return fail("unknown_kid");
    try {
      if (jwk.kty !== "RSA" || (jwk.alg && jwk.alg !== "RS256") || (jwk.use && jwk.use !== "sig")) throw new Error();
      const key = await crypto.subtle.importKey("jwk", jwk, { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["verify"]);
      if (!await crypto.subtle.verify("RSASSA-PKCS1-v1_5", key, signature,
        new TextEncoder().encode(`${parts[0]}.${parts[1]}`))) return fail("bad_signature");
    } catch { return fail("bad_signature"); }
    if (claims.iss !== ISSUER) return fail("wrong_issuer");
    if (claims.aud !== audience) return fail("wrong_audience");
    if (!Number.isFinite(claims.exp) || time / 1000 >= claims.exp + 60) return fail("expired");
    if (!Number.isFinite(claims.nbf) || claims.nbf > time / 1000 + 60) return fail("not_yet_valid");
    if (typeof claims.repository_owner !== "string" || !allowedOwners.includes(claims.repository_owner)) return fail("owner_not_allowed");
    if (!allowedRepos.includes(claims.repository)) return fail("repo_not_allowed");
    if (typeof claims.ref !== "string" || !(claims.ref === "refs/heads/master" ||
        claims.ref === "refs/heads/main")) return fail("ref_not_allowed");
    if (typeof claims.event_name !== "string") return fail("event_not_allowed");
    if (claims.event_name.startsWith("pull_request")) return fail(
      claims.event_name === "pull_request_target" ? "pull_request_target" : "pull_request");
    if (!["push", "workflow_dispatch"].includes(claims.event_name)) return fail("event_not_allowed");
    return { ok: true, claims };
  } catch { return fail("invalid_input"); }
}
