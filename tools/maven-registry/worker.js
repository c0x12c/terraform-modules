import { verifyGithubOidc } from "./oidc.js";

const jsonRes = (value, status = 200, headers = {}) => new Response(JSON.stringify(value), {
  status, headers: { "content-type": "application/json", ...headers },
});
const list = (value) => value.split(",").map((s) => s.trim()).filter(Boolean);
const allowedFile = (name) => /\.(jar|pom|module|xml|aar|war|klib|zip|tar\.gz|asc|md5|sha1|sha256|sha512)$/.test(name);
const contentType = (name) => /\.(xml|pom)$/.test(name) ? "text/plain; charset=utf-8" :
  name.endsWith(".module") ? "application/json" : /\.(asc|md5|sha1|sha256|sha512)$/.test(name) ? "text/plain" :
  name.endsWith(".jar") ? "application/java-archive" : "application/octet-stream";
const unauthorized = () => jsonRes({ error: "Unauthorized" }, 401, {
  "WWW-Authenticate": "Basic realm=maven-publish",
});
function token(header) {
  const match = /^(Basic|Bearer)\s+(\S+)$/i.exec(header || "");
  if (!match) return null;
  if (match[1].toLowerCase() === "bearer") return match[2];
  try {
    const decoded = atob(match[2]), colon = decoded.indexOf(":");
    return colon > 0 ? decoded.slice(colon + 1) || null : null;
  } catch { return null; }
}
export function makeWorker(verify) {
  return { async fetch(request, env) {
    try {
      // Inspect the supplied path before URL parsing can normalize dot segments.
      const path = /^[a-z][a-z0-9+.-]*:\/\/[^/?#]+([^?#]*)/i.exec(request.url)?.[1] || "";
      const key = path.slice(1), segments = key.split("/");
      if (!path.startsWith("/") || !key || /%2e|%2f|%5c/i.test(path) ||
          /[^A-Za-z0-9._+/-]/.test(path) || path.includes("//") ||
          segments.some((s) => s === "." || s === "..")) return jsonRes({ error: "Invalid path" }, 400);
      const method = request.method;
      if (!["GET", "HEAD", "PUT"].includes(method)) {
        return jsonRes({ error: "Method not allowed" }, 405, { Allow: "GET, HEAD, PUT" });
      }
      if (method === "GET" && path === "/healthz") return jsonRes({ status: "ok" });
      if (method === "PUT") {
        if (segments.length < 2) return jsonRes({ error: "Invalid path" }, 400);
        const jwt = token(request.headers.get("Authorization"));
        if (!jwt) return unauthorized();
        const result = await verify(jwt, {
          audience: env.OIDC_AUDIENCE ?? "c0x12c-maven-publish",
          allowedOwners: list(env.ALLOWED_OWNERS ?? "c0x12c"),
          allowedRepos: list(env.ALLOWED_REPOS ?? ""),
        });
        if (!result.ok) return unauthorized();
        if (!allowedFile(segments.at(-1))) return jsonRes({ error: "Unsupported file type" }, 415);
        const length = request.headers.get("Content-Length");
        if (length === null) return jsonRes({ error: "Length required" }, 411);
        if (!/^\d+$/.test(length)) return jsonRes({ error: "Invalid length" }, 400);
        if (Number(length) > Number(env.MAX_BYTES ?? 104857600)) return jsonRes({ error: "Too large" }, 413);
        const mutable = /^maven-metadata\.xml(?:\.(?:md5|sha1|sha256|sha512))?$/.test(segments.at(-1));
        if (await env.BUCKET.head(key) && !mutable) return jsonRes({ error: "Already exists" }, 409);
        // Conditional writes prevent concurrent publishers from overwriting immutable artifacts.
        const stored = await env.BUCKET.put(key, request.body, {
          httpMetadata: { contentType: contentType(key) },
          ...(!mutable ? { onlyIf: { etagDoesNotMatch: '*' } } : {}),
        });
        if (!mutable && stored === null) return jsonRes({ error: "Already exists" }, 409);
        return new Response(null, { status: 201 });
      }
      const object = await env.BUCKET[method === "HEAD" ? "head" : "get"](key);
      if (!object) return jsonRes({ error: "Not found" }, 404);
      return new Response(method === "HEAD" ? null : object.body, {
        headers: { "content-type": contentType(key), etag: object.httpEtag ?? object.etag,
          "x-content-type-options": "nosniff", "content-security-policy": "default-src 'none'; sandbox" },
      });
    } catch {
      // Exception details can contain credentials supplied to the verifier.
      return jsonRes({ error: "Service unavailable" }, 503);
    }
  } };
}
export default makeWorker(verifyGithubOidc);
