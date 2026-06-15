<!-- BEGIN_TF_DOCS -->

## Usage

```hcl
module "logging_monitor" {
  source  = "terraform.c0x12c.com/c0x12c/logging-monitor/datadog"
  version = "0.0.1"

  environment = "production"
}
```

## Requirements

| Name                                                                      | Version   |
|---------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8  |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog)       | >= 3.46.0 |

## Providers

| Name                                                          | Version   |
|---------------------------------------------------------------|-----------|
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | >= 3.46.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                           | Type     |
|--------------------------------------------------------------------------------------------------------------------------------|----------|
| [datadog_monitor.high_number_of_errors](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.http_4xx](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/monitor)              | resource |
| [datadog_monitor.http_5xx](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/monitor)              | resource |
| [datadog_monitor.new_issue](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/monitor)             | resource |

## Inputs

| Name                                                                                                    | Description | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | Default | Required |
|---------------------------------------------------------------------------------------------------------|-------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment)                                     | n/a         | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | n/a     |   yes    |
| <a name="input_http_4xx"></a> [http\_4xx](#input\_http\_4xx)                                            | n/a         | <pre>object({<br/>    name                    = string<br/>    priority                = optional(number, 2)<br/>    message                 = optional(string, null)<br/>    service_regex           = optional(string, "*")<br/>    critical                = optional(number, 1)<br/>    critical_recovery       = optional(number, 0)<br/>    time_window             = optional(string, "5m")<br/>    additional_filter_regex = optional(string, "")<br/>  })</pre> | `null`  |    no    |
| <a name="input_http_5xx"></a> [http\_5xx](#input\_http\_5xx)                                            | n/a         | <pre>object({<br/>    name                    = string<br/>    priority                = optional(number, 2)<br/>    message                 = optional(string, null)<br/>    service_regex           = optional(string, "*")<br/>    critical                = optional(number, 1)<br/>    critical_recovery       = optional(number, 0)<br/>    time_window             = optional(string, "5m")<br/>    additional_filter_regex = optional(string, "")<br/>  })</pre> | `null`  |    no    |
| <a name="input_high_number_of_errors"></a> [high\_number\_of\_errors](#input\_high\_number\_of\_errors) | n/a         | <pre>object({<br/>    name                    = string<br/>    priority                = optional(number, 5)<br/>    message                 = optional(string, null)<br/>    service_regex           = optional(string, "*")<br/>    source                  = optional(string, "all")<br/>    critical                = optional(number, 1)<br/>    critical_recovery       = optional(number, 0)<br/>    additional_filter_regex = optional(string, "")<br/>    time_window             = optional(string, "1d")<br/>  })</pre> | `null`  |    no    |
| <a name="input_new_issue"></a> [new\_issue](#input\_new\_issue)                                         | n/a         | <pre>object({<br/>    name                    = string<br/>    priority                = optional(number, 5)<br/>    message                 = optional(string, null)<br/>    service_regex           = optional(string, "*")<br/>    source                  = optional(string, "all")<br/>    critical                = optional(number, 1)<br/>    critical_recovery       = optional(number, 0)<br/>    additional_filter_regex = optional(string, "")<br/>    time_window             = optional(string, "1d")<br/>  })</pre> | `null`  |    no    |
| <a name="input_require_full_window"></a> [require\_full\_window](#input\_require\_full\_window)         | n/a         | `bool`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | `false` |    no    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->