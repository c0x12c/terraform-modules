module "dashboard" {
  source = "../../"

  layout_type = "ordered"
  title       = "Example Dashboard"

  template_variables = [
    {
      name             = "env"
      prefix           = "env"
      available_values = ["dev", "prod"]
      default          = "dev"
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
