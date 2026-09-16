# Contributing

This monorepo holds every c0x12c Terraform module. Each
`terraform-<provider>-<name>/` folder is an independently versioned module
published to the self-hosted registry at `terraform.c0x12c.com`.

For the end-to-end release flow (PR → CI → release PR → publish) and
troubleshooting, see the [README](README.md). This guide covers the
conventions a contributor needs.

## Module layout

Each module folder is a flat Terraform root module:

```
terraform-<provider>-<name>/
  main.tf            # resources (may split into iam.tf, locals.tf, etc.)
  variables.tf       # inputs
  outputs.tf         # outputs
  versions.tf        # required_version + required_providers
  README.md          # usage; terraform-docs keeps the inputs/outputs table
  examples/          # at least one runnable example
  .pre-commit-config.yaml
```

- **Naming:** `terraform-<provider>-<name>` (e.g. `terraform-aws-rds`,
  `terraform-datadog-service-monitor`). This maps to the registry source
  `terraform.c0x12c.com/c0x12c/<name>/<provider>`.
- **Provider versions:** pin an upper bound when a provider release can break
  the schema — a floating `>= x` can fail `validate` with no change on our side.
- **Sibling dependencies:** reference another module by **relative path**
  (`source = "../terraform-<provider>-<name>"`) so cross-module changes are
  testable in one PR. The publish job rewrites it to a registry source with an
  exact version pin at release time — never hardcode the registry source for a
  sibling in-repo.

## Local checks

CI runs `terraform fmt -check`, `terraform validate`, `tflint`, and a
`terraform-docs` check for every changed module.

`pre-commit` is configured per module, not at the repo root, so run it from
inside the module you changed:

```bash
pip install pre-commit
cd terraform-<provider>-<name> && pre-commit run -a   # terraform_fmt + terraform_tflint
```

Regenerate the docs with the version CI pins, `v0.20.0`. A newer terraform-docs
(Homebrew currently ships v0.21.0) emits an extra Requirements row from
`override.tofu` and fails the check with the same message a genuinely stale
README produces, so a regeneration with the wrong version reads as "the regen
did not work". Homebrew has no versioned formula for it, so fetch the pinned
binary rather than relying on whatever is on `PATH`:

```bash
cd terraform-<provider>-<name>
curl -sSL https://github.com/terraform-docs/terraform-docs/releases/download/v0.20.0/terraform-docs-v0.20.0-$(uname | tr '[:upper:]' '[:lower:]')-amd64.tar.gz \
  | tar -xz -C /tmp terraform-docs
terraform init -backend=false            # CI runs this before the docs check
/tmp/terraform-docs markdown table --output-file README.md --output-mode inject .
```

The `terraform init` matters: CI runs it first, so terraform-docs reads
`.terraform.lock.hcl` and the Providers table holds the exact versions the
runner resolved. Regenerating without a matching lock file produces the
`versions.tf` constraints instead, and the check fails.

The exception is a module with its own `.terraform-docs.yml` setting
`lockfile: false` (`terraform-aws-health-notification`,
`terraform-datadog-aws-integration`). Those deliberately keep the constraints,
and terraform-docs picks the setting up from the config file.

## Commits & versioning

Use [Conventional Commits](https://www.conventionalcommits.org/) — release
automation derives the version bump from the prefix and opens a per-module
release PR:

| Prefix | Bump (≥ 1.0) | Bump (0.x) |
|---|---|---|
| `fix:` | patch | patch |
| `feat:` | minor | minor |
| `feat!:` / `BREAKING CHANGE:` | major | minor |
| `chore:` `docs:` `ci:` `refactor:` | none | none |

A commit counts toward the next version of whatever module's files it touches.
Edit several modules in one PR — review and CI are atomic, and release
automation opens one release PR per touched module.

## Adding a module

Copy the [`_template/`](_template) scaffold to `terraform-<provider>-<name>/`
(it has the layout above pre-wired), fill in the resources, then add it to
`module-release-config.json` (`packages`), seed `.module-versions.json` with
`"0.0.0"`, and open the PR. No mirror repo or registration is needed — once the
first release PR merges it publishes straight to R2. Keep the module list in
sync across the disk folders, `module-release-config.json`, and
`.module-versions.json` (the `drift` CI job enforces this).

## Consuming a module

```hcl
module "rds" {
  source  = "terraform.c0x12c.com/c0x12c/rds/aws"
  version = "~> 0.6"
}
```

See [MODULES.md](MODULES.md) for the full catalog.
