# terraform-<provider>-<name>

> Scaffold for a new c0x12c Terraform module. Copy this `_template/` folder to
> `terraform-<provider>-<name>/`, then follow CONTRIBUTING.md → "Adding a module".

One-line description of what this module provisions.

## Usage

```hcl
module "<name>" {
  source  = "terraform.c0x12c.com/c0x12c/<name>/<provider>"
  version = "~> 0.1"

  name = "example"
}
```

## Examples

See [`examples/complete`](examples/complete) for a runnable example.
