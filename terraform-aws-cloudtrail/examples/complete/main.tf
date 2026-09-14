module "cloudtrail" {
  source = "../../"

  name                          = "example-cloudtrail"
  enable_logging                = true
  include_global_service_events = true
  versioning_status             = "Enabled"

  lifecycle_rules = [{
    id = "audit-retention"

    transitions = [{
      days          = 90
      storage_class = "GLACIER_IR"
    }]

    expiration_days = 365

    # Versioning is on above, so noncurrent versions need their own expiry or they are the thing
    # that grows without bound.
    noncurrent_version_expiration_days = 90
    abort_incomplete_mpu_days          = 7
  }]
}
