terraform {
  # OpenTofu reads this .tofu override in addition to versions.tf and merges the
  # terraform block. The OpenTofu floor is intentionally lower than the Terraform
  # pin in versions.tf — OpenTofu 1.8 maps to the Terraform 1.9.8 feature set this
  # module targets. This dual-tool pattern matches every other module; keep both
  # floors in sync when bumping. (Terraform ignores .tofu files entirely.)
  required_version = ">= 1.8.0"
}
