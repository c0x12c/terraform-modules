locals {
  http_5xx = {
    name          = "5xx responses detected"
    priority      = 2
    service_regex = "service-platform"
    time_window   = "5m"
    message       = <<EOT
5xx responses detected for service {{service.name}} on resource {{resource_name}}.
EOT
  }

  http_4xx = {
    name          = "4xx responses detected"
    priority      = 2
    service_regex = "service-platform"
    time_window   = "5m"
    message       = <<EOT
4xx responses detected for service {{service.name}} on resource {{resource_name}}.
EOT
  }

  high_number_of_errors = {
    name                    = "High number of errors detected"
    priority                = 5
    message                 = <<EOT
High number of errors on [issue]({{ issue.link }}) detected.

{{#is_alert}}
```
{{issue.attributes.error.type}}: {{issue.attributes.error.message}}
```
{{/is_alert}}
EOT
    service_regex           = "service-platform"
    source                  = "all"
    critical                = 1
    critical_recovery       = 0
    additional_filter_regex = ""
    time_window             = "1d"
  }

  new_issue = {
    name                    = "New issue detected"
    priority                = 5
    message                 = <<EOT
    A new [issue]({{ issue.link }}) has been detected.

{{#is_alert}}
```
{{issue.attributes.error.type}}: {{issue.attributes.error.message}}
```
{{/is_alert}}

Mark the issue as Reviewed to stop receiving this alert.
EOT
    service_regex           = "service-platform"
    source                  = "all"
    critical                = 1
    critical_recovery       = 0
    additional_filter_regex = ""
    time_window             = "1d"
  }
}
module "logging_monitor" {
  source = "../../logging-monitor"

  environment         = "dev"
  require_full_window = false

  http_5xx = local.http_5xx
  http_4xx = local.http_4xx

  high_number_of_errors = local.high_number_of_errors
  new_issue             = local.new_issue
}
