locals {
  identity_store_id = data.aws_ssoadmin_instances.sso.identity_store_ids[0]
}
