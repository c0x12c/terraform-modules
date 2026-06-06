module "kms" {
  source                   = "../../"
  alias_name               = ["example"]
  description              = "example"
  deletion_window_in_days  = 7
  key_usage                = "ENCRYPT_DECRYPT"
  custom_key_store_id      = null
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = false
  enabled_create_policy    = true
}
