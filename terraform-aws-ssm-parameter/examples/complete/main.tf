module "ssm_parameters" {
  source = "../../"

  prefix = "example"
  parameters = {
    "key-1" = {
      value       = "example-1"
      description = "example 1 description"
      insecure    = false
    },
    "key-2" = {
      value       = "example-2"
      description = "example 2 description"
      insecure    = true
    },
    "key-3" = {
      values      = ["example-3"]
      description = "example 3 description"
      insecure    = false
    }
  }
}
