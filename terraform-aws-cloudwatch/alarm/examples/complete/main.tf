module "cloudwatch_alarm" {
  source = "../../"

  email       = "example-email"
  environment = "dev"
  alarms = {
    CPUUtilization = {
      name                = "example-alarm"
      description         = "example"
      comparison_operator = "example-comparison"
      evaluation_periods  = "1"
      metric_name         = "exammple-metric"
      namespace           = "example-namespace"
      period              = "example-period"
      statistic           = "Average"
      threshold           = "20"
    }
  }
}
