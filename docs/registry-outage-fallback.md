# What to do when the module registry is unreachable

When `terraform.c0x12c.com` is unreachable, `terraform init` retries twice and then
fails hard. There is no automatic recovery in the module client, so every affected
apply stops until the registry returns or you take one of the actions below.

Note that Terraform's `provider_installation` / `network_mirror` CLI settings apply
to **providers only**. There is no module equivalent, so those blocks will not help
here.

## 1. Reuse an already-initialised module cache (least effort)

`terraform init` only downloads a module when it is missing from `.terraform/modules`
or when its version constraint changed. A working directory that was initialised
before the outage keeps working, and CI keeps working if `.terraform/modules` and
`.terraform/modules/modules.json` are restored from the job cache rather than fetched
fresh. If your pipeline currently discards that directory between runs, caching it is
the single cheapest thing that makes CI survive a registry outage.

## 2. Switch the source to a git ref (per module, reversible)

Each module is developed in the `terraform-modules` monorepo, so a module can be
sourced directly from git for the duration of the outage:

```hcl
module "rds" {
  source = "git::https://github.com/c0x12c/terraform-modules.git//terraform-aws-rds?ref=terraform-aws-rds/v1.1.0"
}
```

Tags are namespaced per module as `<folder>/v<version>`, so the ref is
`terraform-aws-rds/v1.1.0`, not `v1.1.0`. Use the tag matching the version you had
pinned. Revert to the registry `source` + `version` pair once the registry is back;
leaving it on a git ref opts the module out of version-constraint resolution.

Caveat: a module that instantiates sibling modules by registry source will still
reach for the registry to resolve them. Check the module's own `.tf` files before
relying on this for a multi-module package.

## 3. Vendor the module (blunt, always works)

Copy the module into the repository and point `source` at a local path. This removes
the registry dependency completely, at the cost of losing version tracking. Reserve it
for a prolonged outage, and remove the vendored copy afterwards.

## Reporting

If the registry is down and no alert has fired, say so in the incident channel - the
uptime probe runs on a 15 minute schedule and is best-effort, so a real outage can
start before it is noticed.
