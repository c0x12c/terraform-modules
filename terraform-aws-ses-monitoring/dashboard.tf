module "datadog_dashboard" {
  source  = "c0x12c/dashboard/datadog"
  version = "~> 1.0.0"

  count = var.enabled_datadog_dashboard == true ? 1 : 0

  title = "SES Outgoing Email Dashboard"

  layout_type = "ordered"
  reflow_type = "fixed"

  template_variables = [
    {
      name             = "env"
      prefix           = "env"
      available_values = var.datadog_dashboard_environments
      default          = var.datadog_dashboard_default_environment
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
                  "query" : "service:${local.dd_service} $env"
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
    },
    {
      "definition" : {
        "title" : "Timeline",
        "title_size" : "16",
        "title_align" : "left",
        "show_legend" : true,
        "legend_layout" : "auto",
        "legend_columns" : [
          "avg",
          "min",
          "max",
          "value",
          "sum"
        ],
        "type" : "timeseries",
        "requests" : [
          {
            "formulas" : [
              {
                "formula" : "query1"
              }
            ],
            "queries" : [
              {
                "name" : "query1",
                "data_source" : "logs",
                "search" : {
                  "query" : "service:${local.dd_service} $env"
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
            "response_format" : "timeseries",
            "style" : {
              "palette" : "datadog16",
              "order_by" : "values",
              "order_reverse" : false,
              "line_type" : "solid",
              "line_width" : "normal"
            },
            "display_type" : "line"
          }
        ]
      },
      "layout" : {
        "x" : 4,
        "y" : 0,
        "width" : 4,
        "height" : 4
      }
    },
    {
      "id" : 7054169211938482,
      "definition" : {
        "title" : "Sender",
        "title_size" : "16",
        "title_align" : "left",
        "type" : "toplist",
        "requests" : [
          {
            "queries" : [
              {
                "name" : "query1",
                "data_source" : "logs",
                "search" : {
                  "query" : "service:${local.dd_service} $env"
                },
                "indexes" : [
                  "*"
                ],
                "group_by" : [
                  {
                    "facet" : "@attributes.mail.source",
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
            "response_format" : "scalar",
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
        "style" : {
          "display" : {
            "type" : "stacked",
            "legend" : "automatic"
          }
        }
      },
      "layout" : {
        "x" : 0,
        "y" : 4,
        "width" : 2,
        "height" : 4
      }
    },
    {
      "definition" : {
        "title" : "Complaint Feedback Type",
        "title_size" : "16",
        "title_align" : "left",
        "type" : "toplist",
        "requests" : [
          {
            "queries" : [
              {
                "name" : "query1",
                "data_source" : "logs",
                "search" : {
                  "query" : "service:${local.dd_service} $env"
                },
                "indexes" : [
                  "*"
                ],
                "group_by" : [
                  {
                    "facet" : "@attributes.complaint.complaintFeedbackType",
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
            "response_format" : "scalar",
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
        "style" : {
          "display" : {
            "type" : "stacked",
            "legend" : "automatic"
          }
        }
      },
      "layout" : {
        "x" : 2,
        "y" : 4,
        "width" : 2,
        "height" : 4
      }
    },
    {
      "id" : 5597663366655448,
      "definition" : {
        "title" : "Bounce Type",
        "title_size" : "16",
        "title_align" : "left",
        "type" : "toplist",
        "requests" : [
          {
            "queries" : [
              {
                "name" : "query1",
                "data_source" : "logs",
                "search" : {
                  "query" : "service:${local.dd_service} $env"
                },
                "indexes" : [
                  "*"
                ],
                "group_by" : [
                  {
                    "facet" : "@attributes.bounce.bounceType",
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
            "response_format" : "scalar",
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
        "style" : {
          "display" : {
            "type" : "stacked",
            "legend" : "automatic"
          }
        }
      },
      "layout" : {
        "x" : 4,
        "y" : 4,
        "width" : 2,
        "height" : 4
      }
    },
    {
      "definition" : {
        "title" : "Bounce Sub Type",
        "title_size" : "16",
        "title_align" : "left",
        "type" : "toplist",
        "requests" : [
          {
            "queries" : [
              {
                "name" : "query1",
                "data_source" : "logs",
                "search" : {
                  "query" : "service:${local.dd_service} $env"
                },
                "indexes" : [
                  "*"
                ],
                "group_by" : [
                  {
                    "facet" : "@attributes.bounce.bounceSubType",
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
            "response_format" : "scalar",
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
        "style" : {
          "display" : {
            "type" : "stacked",
            "legend" : "automatic"
          }
        }
      },
      "layout" : {
        "x" : 6,
        "y" : 4,
        "width" : 2,
        "height" : 4
      }
    }
  ]
}
