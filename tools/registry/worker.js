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

const DISCOVERY = { "modules.v1": "/v1/modules/" };
const jsonRes = (o, status = 200) =>
  new Response(JSON.stringify(o), { status, headers: { "content-type": "application/json" } });

export default {
  async fetch(req, env) {
    const url = new URL(req.url);
    const p = url.pathname;

    if (p === "/.well-known/terraform.json") return jsonRes(DISCOVERY);

    // List versions
    let m = p.match(/^\/v1\/modules\/([^/]+)\/([^/]+)\/([^/]+)\/versions$/);
    if (m) {
      const idxObj = await env.BUCKET.get("index.json");
      if (!idxObj) return jsonRes({ errors: ["registry empty"] }, 500);
      const idx = JSON.parse(await idxObj.text());
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
      const obj = await env.BUCKET.get(key);
      if (!obj) return new Response("not found", { status: 404 });
      return new Response(obj.body, { headers: { "content-type": "application/gzip" } });
    }

    return new Response("not found", { status: 404 });
  },
};
