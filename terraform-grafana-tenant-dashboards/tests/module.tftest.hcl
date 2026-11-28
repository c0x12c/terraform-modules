mock_provider "grafana" {}

variables {
  project = "example"
  environments = {
    dev = {
      namespace    = "service-example-dev"
      service_name = "backend"
      pod_regex    = "example-api-[a-z0-9]+-[a-z0-9]+"
    }
    prod = {
      namespace       = "service-example-prod"
      service_name    = "api"
      pod_regex       = "example-worker-.*"
      container       = "app"
      aws_tag_project = "shared-example"
    }
  }
}

run "defaults" {
  command = plan

  assert {
    condition = alltrue([
      for key, dashboard in grafana_dashboard.this :
      jsondecode(dashboard.config_json).uid == "example-${replace(key, "/", "-")}"
    ]) && length(grafana_dashboard.this) == 12
    error_message = "Every enabled preset must have an explicit project-env-preset uid."
  }

  assert {
    condition = alltrue([
      for env, folder in grafana_folder.env :
      folder.parent_folder_uid == "example" && folder.uid == "example-${env}" && folder.prevent_destroy_if_not_empty
    ]) && grafana_folder.parent.uid == "example" && grafana_folder.parent.prevent_destroy_if_not_empty
    error_message = "Environment folders must be parented and protected from deleting contents."
  }

  assert {
    condition = alltrue([
      for key, dashboard in grafana_dashboard.this :
      dashboard.folder == "example-${split("/", key)[0]}" && dashboard.overwrite &&
      !contains(keys(jsondecode(dashboard.config_json)), "id") &&
      !contains(keys(jsondecode(dashboard.config_json)), "version") &&
      alltrue([
        for panel in jsondecode(dashboard.config_json).panels :
        try(panel.datasource.uid == "$${DS_PROMETHEUS}", true)
      ])
    ])
    error_message = "Rendering must keep literal datasource references, remove server metadata and use the env folder."
  }

  assert {
    condition = alltrue(flatten([
      for env, cfg in var.environments : [
        for preset in var.enabled_presets : [
          for constant in jsondecode(grafana_dashboard.this["${env}/${preset}"].config_json).templating.list :
          constant.query == {
            namespace       = cfg.namespace
            service_name    = cfg.service_name
            pod_regex       = cfg.pod_regex
            container       = cfg.container
            aws_tag_project = coalesce(try(cfg.aws_tag_project, null), var.project)
          }[constant.name] &&
          constant.current.text == constant.query &&
          constant.current.value == constant.query &&
          constant.options[0].text == constant.query &&
          constant.options[0].value == constant.query &&
          constant.options[0].selected && constant.hide == 2
          if constant.type == "constant"
        ]
      ]
    ]))
    error_message = "All hidden constants must be replaced, including project fallback and per-env AWS tag overrides."
  }

  assert {
    condition = alltrue(flatten([
      for dashboard in values(grafana_dashboard.this) : [
        for panel in jsondecode(dashboard.config_json).panels : [
          for target in try(panel.targets, []) :
          !strcontains(target.expr, "container=\"spartan\"")
        ]
      ]
      ])) && alltrue(flatten([
      for env in keys(var.environments) : [
        for panel in jsondecode(grafana_dashboard.this["${env}/pods"].config_json).panels : [
          for target in try(panel.targets, []) :
          strcontains(target.expr, "container=\"$container\"")
          if strcontains(target.expr, "container=")
        ]
      ]
      ])) && alltrue([
      for env in keys(var.environments) :
      anytrue(flatten([
        for panel in jsondecode(grafana_dashboard.this["${env}/pods"].config_json).panels : [
          for target in try(panel.targets, []) :
          strcontains(target.expr, "container=\"$container\"")
        ]
      ]))
    ])
    error_message = "Rendered queries must not hardcode the workload container; pods container filters must use the container constant."
  }

  assert {
    condition = alltrue(flatten([
      for env in keys(var.environments) : [
        for preset in ["pods", "runtime"] : [
          for panel in jsondecode(grafana_dashboard.this["${env}/${preset}"].config_json).panels : [
            for target in try(panel.targets, []) :
            strcontains(target.expr, "pod=~\"$pod_regex\"") || strcontains(target.expr, "k8s_pod_name=~\"$pod_regex\"") ||
            strcontains(target.expr, "durable_queue_depth")
          ]
        ]
      ]
    ]))
    error_message = "Pod metrics must use the deployment regex, including waiting containers."
  }

  assert {
    condition = alltrue(flatten([
      for env in keys(var.environments) : [
        for preset in ["elasticache", "rds"] : [
          for panel in jsondecode(grafana_dashboard.this["${env}/${preset}"].config_json).panels : [
            for target in try(panel.targets, []) :
            strcontains(target.expr, "namespace=\"$namespace\"") &&
            strcontains(target.expr, "name!=\"global\"") &&
            strcontains(target.expr, "tag_Project=\"$aws_tag_project\"")
          ]
        ]
      ]
    ]))
    error_message = "Every AWS metric must be scoped by namespace and project while excluding global metrics."
  }

  assert {
    condition = alltrue([
      for panel in jsondecode(grafana_dashboard.this["dev/red"].config_json).panels :
      panel.fieldConfig.defaults.thresholds.steps[1].value == (panel.id == 2 ? 0.05 : 1) &&
      panel.fieldConfig.defaults.thresholds.steps[1].color == "red" &&
      panel.fieldConfig.defaults.custom.thresholdsStyle.mode == "line"
      if contains([2, 3], panel.id)
    ])
    error_message = "Default RED thresholds must be visible at 5 percent and one second."
  }

  assert {
    condition     = jsondecode(grafana_dashboard.this["dev/pods"].config_json).title == "example dev - Backend pods"
    error_message = "Default titles must include the project and environment."
  }
}

run "adoption_overrides_and_extra" {
  command = plan

  variables {
    folder_uids = {
      parent = "existing-parent"
      envs   = { dev = "existing-dev", prod = "existing-prod" }
    }
    red_thresholds = { p95_seconds = 2.5, error_ratio = 0.02 }
    dashboard_overrides = {
      pods    = { enabled = false }
      runtime = { title = "Custom runtime" }
    }
    extra_dashboards = {
      custom = jsonencode({
        id      = 123
        version = 9
        title   = "Custom dashboard"
        panels  = []
      })
    }
  }

  assert {
    condition = grafana_folder.parent.uid == "existing-parent" && alltrue([
      for env, folder in grafana_folder.env :
      folder.uid == "existing-${env}" && folder.parent_folder_uid == "existing-parent"
    ]) && grafana_dashboard.this["dev/runtime"].folder == "existing-dev"
    error_message = "Explicit folder uids must be used for adoption and dashboard placement."
  }

  assert {
    condition = (!contains(keys(grafana_dashboard.this), "dev/pods") &&
      !contains(keys(grafana_dashboard.this), "prod/pods") &&
    jsondecode(grafana_dashboard.this["dev/runtime"].config_json).title == "Custom runtime")
    error_message = "Overrides must drop disabled dashboards and replace titles independently."
  }

  assert {
    condition = (jsondecode(grafana_dashboard.this["dev/custom"].config_json).uid == "example-dev-custom" &&
      jsondecode(grafana_dashboard.this["prod/custom"].config_json).title == "example prod - Custom dashboard" &&
      !contains(keys(jsondecode(grafana_dashboard.this["dev/custom"].config_json)), "id") &&
    !contains(keys(jsondecode(grafana_dashboard.this["dev/custom"].config_json)), "version"))
    error_message = "Extra dashboards must render in each environment without server metadata."
  }

  assert {
    condition = alltrue([
      for panel in jsondecode(grafana_dashboard.this["dev/red"].config_json).panels :
      panel.fieldConfig.defaults.thresholds.steps[1].value == (panel.id == 2 ? 0.02 : 2.5)
      if contains([2, 3], panel.id)
    ])
    error_message = "Caller RED thresholds must replace both default values."
  }
}

run "uid_too_long" {
  command = plan
  variables {
    project = "abcdefghijklmnopqrstuvwxyzabcdef"
  }
  expect_failures = [var.project]
}

run "unknown_preset" {
  command = plan
  variables {
    enabled_presets = ["unknown"]
  }
  expect_failures = [var.enabled_presets]
}

run "scrape_interval_null_adds_no_keys" {
  command = plan

  variables {
    extra_dashboards = {
      custom = jsonencode({
        title = "Custom dashboard"
        panels = [
          { id = 1, type = "timeseries", targets = [{ expr = "up" }] },
          { id = 2, type = "row", panels = [{ id = 3, type = "timeseries", targets = [{ expr = "up" }] }] },
        ]
      })
    }
  }

  assert {
    condition = alltrue(flatten([
      for dashboard in values(grafana_dashboard.this) : [
        for panel in jsondecode(dashboard.config_json).panels : [
          !contains(keys(panel), "interval"),
          alltrue([for target in try(panel.targets, []) : !contains(keys(target), "interval")]),
          alltrue([for child in try(panel.panels, []) : !contains(keys(child), "interval")]),
        ]
      ]
    ]))
    error_message = "A null scrape_interval must not add interval keys to any panel or target."
  }
}

run "scrape_interval_set" {
  command = plan

  variables {
    scrape_interval = "1m"
    extra_dashboards = {
      custom = jsonencode({
        title = "Custom dashboard"
        panels = [
          { id = 1, type = "timeseries", targets = [{ expr = "up" }] },
          { id = 2, type = "row", panels = [{ id = 3, type = "timeseries", targets = [{ expr = "up" }] }] },
        ]
      })
    }
  }

  assert {
    condition = alltrue(flatten([
      for panel in jsondecode(grafana_dashboard.this["dev/pods"].config_json).panels : [
        panel.interval == "1m",
        alltrue([for target in panel.targets : target.interval == "1m"]),
      ]
      if length(try(panel.targets, [])) > 0
    ])) && anytrue([for panel in jsondecode(grafana_dashboard.this["dev/pods"].config_json).panels : length(try(panel.targets, [])) > 0])
    error_message = "A preset's panels with targets must carry the interval on the panel and each target."
  }

  assert {
    condition = alltrue(flatten([
      for panel in jsondecode(grafana_dashboard.this["dev/pods"].config_json).panels : [
        !contains(keys(panel), "interval")
      ]
      if length(try(panel.targets, [])) == 0
    ]))
    error_message = "Panels without targets must not get an interval."
  }

  assert {
    condition = (
      jsondecode(grafana_dashboard.this["prod/custom"].config_json).panels[0].interval == "1m" &&
      jsondecode(grafana_dashboard.this["prod/custom"].config_json).panels[0].targets[0].interval == "1m" &&
      !contains(keys(jsondecode(grafana_dashboard.this["prod/custom"].config_json).panels[1]), "interval") &&
      jsondecode(grafana_dashboard.this["prod/custom"].config_json).panels[1].panels[0].interval == "1m" &&
      jsondecode(grafana_dashboard.this["prod/custom"].config_json).panels[1].panels[0].targets[0].interval == "1m"
    )
    error_message = "Extra dashboards must be stamped, including panels nested in rows."
  }
}

run "scrape_interval_invalid" {
  command = plan
  variables {
    scrape_interval = "one minute"
  }
  expect_failures = [var.scrape_interval]
}
