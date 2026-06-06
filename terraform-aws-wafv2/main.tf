resource "aws_wafv2_web_acl" "this" {
  name        = var.name
  description = "WAFv2 ACL for ${var.name}"
  scope       = var.scope

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    sampled_requests_enabled   = var.sampled_requests_enabled
    metric_name                = var.name
  }

  dynamic "rule" {
    for_each = var.managed_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority
      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = rule.value.vendor_name
          version     = rule.value.version
          dynamic "rule_action_override" {
            for_each = rule.value.rule_action_override
            content {
              name = rule_action_override.value["name"]
              action_to_use {
                dynamic "allow" {
                  for_each = rule_action_override.value["action_to_use"] == "allow" ? [1] : []
                  content {}
                }
                dynamic "block" {
                  for_each = rule_action_override.value["action_to_use"] == "block" ? [1] : []
                  content {}
                }
                dynamic "count" {
                  for_each = rule_action_override.value["action_to_use"] == "count" ? [1] : []
                  content {}
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.ip_sets_rule
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {
            custom_response {
              response_code = rule.value.response_code
              response_header {
                name  = "Access-Control-Allow-Origin"
                value = "*"
              }
              response_header {
                name  = "Access-Control-Allow-Methods"
                value = "*"
              }
            }
          }
        }
      }

      statement {
        ip_set_reference_statement {
          arn = rule.value.ip_set_arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.ip_rate_based_rule != null ? [var.ip_rate_based_rule] : []
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {
            custom_response {
              response_code = rule.value.response_code
              response_header {
                name  = "Access-Control-Allow-Origin"
                value = "*"
              }
              response_header {
                name  = "Access-Control-Allow-Methods"
                value = "*"
              }
            }
          }
        }
      }

      statement {
        rate_based_statement {
          limit                 = rule.value.limit
          aggregate_key_type    = "IP"
          evaluation_window_sec = rule.value.evaluation_window_sec
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.ip_rate_url_based_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {
            custom_response {
              response_code = rule.value.response_code
              response_header {
                name  = "Access-Control-Allow-Origin"
                value = "*"
              }
              response_header {
                name  = "Access-Control-Allow-Methods"
                value = "*"
              }
            }
          }
        }
      }

      statement {
        rate_based_statement {
          limit                 = rule.value.limit
          aggregate_key_type    = "IP"
          evaluation_window_sec = rule.value.evaluation_window_sec

          scope_down_statement {
            byte_match_statement {
              positional_constraint = rule.value.positional_constraint
              search_string         = rule.value.search_string
              field_to_match {
                uri_path {}
              }
              text_transformation {
                priority = 0
                type     = "URL_DECODE"
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = [for header_name in try(var.filtered_header_rule.header_types, []) : {
      priority      = var.filtered_header_rule.priority + index(var.filtered_header_rule.header_types, header_name) + 1
      name          = header_name
      header_value  = var.filtered_header_rule.header_value
      action        = var.filtered_header_rule.action
      search_string = var.filtered_header_rule.search_string
    }]

    content {
      name     = replace(rule.value.name, ".", "-")
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
      }

      statement {
        byte_match_statement {
          field_to_match {
            single_header {
              name = rule.value.header_value
            }
          }
          positional_constraint = "EXACTLY"
          search_string         = rule.value.search_string != "" ? rule.value.search_string : rule.value.name
          text_transformation {
            priority = rule.value.priority
            type     = "COMPRESS_WHITE_SPACE"
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = replace(rule.value.name, ".", "-")
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.group_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        rule_group_reference_statement {
          arn = rule.value.arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.geo_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {
            custom_response {
              response_code = rule.value.response_code
              response_header {
                name  = "Access-Control-Allow-Origin"
                value = "*"
              }
              response_header {
                name  = "Access-Control-Allow-Methods"
                value = "*"
              }
            }
          }
        }
      }

      statement {
        # If there are excluded paths, wrap in AND NOT statement
        dynamic "and_statement" {
          for_each = length(var.excluded_paths) > 0 ? [1] : []
          content {
            # First part: the original geo rule logic
            statement {
              # Geo match for country-based labeling
              dynamic "geo_match_statement" {
                for_each = rule.value.type == "geo_match" && length(rule.value.country_codes) > 0 ? [1] : []
                content {
                  country_codes = rule.value.country_codes
                }
              }

              # Not statement for blocking based on absence of labels
              dynamic "not_statement" {
                for_each = rule.value.type == "not_labels" && length(rule.value.label_keys) > 0 ? [1] : []
                content {
                  statement {
                    dynamic "or_statement" {
                      for_each = length(rule.value.label_keys) > 1 ? [1] : []
                      content {
                        dynamic "statement" {
                          for_each = rule.value.label_keys
                          content {
                            label_match_statement {
                              scope = "LABEL"
                              key   = statement.value
                            }
                          }
                        }
                      }
                    }
                    # Single label case (no OR needed)
                    dynamic "label_match_statement" {
                      for_each = length(rule.value.label_keys) == 1 ? [rule.value.label_keys[0]] : []
                      content {
                        scope = "LABEL"
                        key   = label_match_statement.value
                      }
                    }
                  }
                }
              }

              # Direct label match for blocking specific states
              dynamic "or_statement" {
                for_each = rule.value.type == "label_match" && length(rule.value.label_keys) > 1 ? [1] : []
                content {
                  dynamic "statement" {
                    for_each = rule.value.label_keys
                    content {
                      label_match_statement {
                        scope = "LABEL"
                        key   = statement.value
                      }
                    }
                  }
                }
              }

              dynamic "label_match_statement" {
                for_each = rule.value.type == "label_match" && length(rule.value.label_keys) == 1 ? [rule.value.label_keys[0]] : []
                content {
                  scope = "LABEL"
                  key   = label_match_statement.value
                }
              }
            }

            # Second part: NOT any of the excluded paths
            statement {
              not_statement {
                statement {
                  # If we have multiple paths to exclude, wrap them in an OR
                  dynamic "or_statement" {
                    for_each = length(var.excluded_paths) > 1 ? [1] : []
                    content {
                      dynamic "statement" {
                        for_each = var.excluded_paths
                        content {
                          byte_match_statement {
                            field_to_match {
                              uri_path {}
                            }
                            positional_constraint = "STARTS_WITH"
                            search_string         = statement.value
                            text_transformation {
                              priority = 0
                              type     = "NONE"
                            }
                          }
                        }
                      }
                    }
                  }
                  # If we only have one path to exclude, no need for OR
                  dynamic "byte_match_statement" {
                    for_each = length(var.excluded_paths) == 1 ? [var.excluded_paths[0]] : []
                    content {
                      field_to_match {
                        uri_path {}
                      }
                      positional_constraint = "STARTS_WITH"
                      search_string         = byte_match_statement.value
                      text_transformation {
                        priority = 0
                        type     = "NONE"
                      }
                    }
                  }
                }
              }
            }
          }
        }

        # If no excluded_paths, use the original logic directly
        dynamic "geo_match_statement" {
          for_each = rule.value.type == "geo_match" && length(rule.value.country_codes) > 0 && length(var.excluded_paths) == 0 ? [1] : []
          content {
            country_codes = rule.value.country_codes
          }
        }

        # Not statement for blocking based on absence of labels (when no excluded paths)
        dynamic "not_statement" {
          for_each = rule.value.type == "not_labels" && length(rule.value.label_keys) > 0 && length(var.excluded_paths) == 0 ? [1] : []
          content {
            statement {
              dynamic "or_statement" {
                for_each = length(rule.value.label_keys) > 1 ? [1] : []
                content {
                  dynamic "statement" {
                    for_each = rule.value.label_keys
                    content {
                      label_match_statement {
                        scope = "LABEL"
                        key   = statement.value
                      }
                    }
                  }
                }
              }
              # Single label case (no OR needed)
              dynamic "label_match_statement" {
                for_each = length(rule.value.label_keys) == 1 ? [rule.value.label_keys[0]] : []
                content {
                  scope = "LABEL"
                  key   = label_match_statement.value
                }
              }
            }
          }
        }

        # Direct label match for blocking specific states (when no excluded paths)
        dynamic "or_statement" {
          for_each = rule.value.type == "label_match" && length(rule.value.label_keys) > 1 && length(var.excluded_paths) == 0 ? [1] : []
          content {
            dynamic "statement" {
              for_each = rule.value.label_keys
              content {
                label_match_statement {
                  scope = "LABEL"
                  key   = statement.value
                }
              }
            }
          }
        }

        dynamic "label_match_statement" {
          for_each = rule.value.type == "label_match" && length(rule.value.label_keys) == 1 && length(var.excluded_paths) == 0 ? [rule.value.label_keys[0]] : []
          content {
            scope = "LABEL"
            key   = label_match_statement.value
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  count        = var.enabled_wafv2_web_acl_association ? 1 : 0
  web_acl_arn  = aws_wafv2_web_acl.this.arn
  resource_arn = var.web_acl_associations_arn
}
