module "cloudtrail" {
  source = "../../"

  name                          = "example-cloudtrail"
  enable_logging                = true
  include_global_service_events = true
}
