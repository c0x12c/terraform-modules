# Datadog Dashboard Terraform module

Terraform module which creates Datadog Dashboard.

## Usage

### Create Dashboard

```hcl
module "dashboard" {
  source  = "c0x12c/dashboard/datadog"
  version = "~> 1.0.0"

  layout_type = "ordered"
  title       = "Example Dashboard"

  template_variables = [
    {
      name    = "env"
      prefix  = "env"
      available_values = ["dev", "prod"]
      default = "dev"
    }
  ]

  widgets = [
    {
      "definition" : {
        "title" : "Summary",
        "title_size" : "16",
        "title_align" : "left",
        "requests" : [
          {
            "response_format" : "scalar",
            "queries" : [
              {
                "name" : "query1",
                "data_source" : "logs",
                "search" : {
                  "query" : "service:example_service $env"
                },
                "indexes" : [
                  "*"
                ],
                "group_by" : [
                  {
                    "facet" : "@attributes.notificationType",
                    "limit" : 10,
                    "sort" : {
                      "aggregation" : "count",
                      "order" : "desc",
                      "metric" : "count"
                    },
                    "should_exclude_missing" : true
                  }
                ],
                "compute" : {
                  "aggregation" : "count"
                },
                "storage" : "hot"
              }
            ],
            "style" : {
              "palette" : "datadog16"
            },
            "formulas" : [
              {
                "formula" : "query1"
              }
            ],
            "sort" : {
              "count" : 10,
              "order_by" : [
                {
                  "type" : "formula",
                  "index" : 0,
                  "order" : "desc"
                }
              ]
            }
          }
        ],
        "type" : "sunburst",
        "hide_total" : false,
        "legend" : {
          "type" : "automatic"
        }
      },
      "layout" : {
        "x" : 0,
        "y" : 0,
        "width" : 4,
        "height" : 4
      }
    }
  ]
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | ~> 3.69.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | ~> 3.69.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [datadog_dashboard_json.this](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/dashboard_json) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | The description of the dashboard. | `string` | `null` | no |
| <a name="input_layout_type"></a> [layout\_type](#input\_layout\_type) | The layout type of the dashboard. Valid values are ordered, free. | `string` | n/a | yes |
| <a name="input_notify_list"></a> [notify\_list](#input\_notify\_list) | The list of handles for the users to notify when changes are made to this dashboard. | `list(string)` | `[]` | no |
| <a name="input_reflow_type"></a> [reflow\_type](#input\_reflow\_type) | The reflow type of a new dashboard layout. Valid values are auto, fixed. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags of dashboard | `list(string)` | `[]` | no |
| <a name="input_template_variables"></a> [template\_variables](#input\_template\_variables) | The list of template variables for this powerpack. | <pre>list(object({<br/>    name             = string<br/>    available_values = optional(list(string), [])<br/>    default          = optional(string, "*")<br/>    prefix           = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_title"></a> [title](#input\_title) | The title of the dashboard. | `string` | n/a | yes |
| <a name="input_widgets"></a> [widgets](#input\_widgets) | The list of widgets to display on the dashboard. | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of this resource. |

<!-- END_TF_DOCS -->
