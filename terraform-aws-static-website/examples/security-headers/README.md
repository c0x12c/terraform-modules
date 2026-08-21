# Security headers on a site with no ordered cache behaviors

The response headers policy is attached to the default cache behavior, so a site that declares no
`ordered_cache_behaviors` still gets its headers.

The CSP is sent whether or not the origin set one, and `override = false` does not suppress it - diff
this policy against what the origin serves today before enabling it on a site that is already live.

## Usage
To run this example you need to execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```
