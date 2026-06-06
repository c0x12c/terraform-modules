module "storage_bucket" {
  source = "../../"

  bucket_name = "example-bucket"
  environment = "example-environment"

  soft_delete_policy = {
    retention_duration_seconds = 604800 # 7 days
  }

  lifecycle_rules = [
    {
      age  = 30
      type = "Delete"
    },
    {
      age  = 60
      type = "SetStorageClass"
    }
  ]

  logging = {
    enabled            = true
    destination_bucket = "log-bucket"
  }
}
