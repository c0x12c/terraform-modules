locals {
  preset_titles = {
    pods        = "Backend pods"
    runtime     = "Backend runtime"
    elasticache = "ElastiCache"
    rds         = "RDS"
    uptime      = "Uptime probe"
    red         = "RED"
  }

  parent_folder_uid = coalesce(var.folder_uids.parent, var.project)

  env_folder_uids = {
    for env in keys(var.environments) :
    env => lookup(coalesce(var.folder_uids.envs, {}), env, "${var.project}-${env}")
  }

  # Invalid presets must reach input validation without attempting to read missing files.
  templates = merge(
    { for p in var.enabled_presets : p => jsondecode(file("${path.module}/dashboards/${p}.json")) if contains(keys(local.preset_titles), p) },
    { for name, json in var.extra_dashboards : name => jsondecode(json) },
  )

  default_titles = merge(
    { for p in var.enabled_presets : p => local.preset_titles[p] if contains(keys(local.preset_titles), p) },
    { for name, tpl in local.templates : name => try(tpl.title, name) if !contains(var.enabled_presets, name) },
  )

  dashboards = {
    for pair in setproduct(keys(var.environments), keys(local.templates)) :
    "${pair[0]}/${pair[1]}" => {
      env  = pair[0]
      name = pair[1]
    }
    if try(var.dashboard_overrides[pair[1]].enabled, true) != false
  }

  constants = {
    for env, cfg in var.environments : env => {
      namespace       = cfg.namespace
      service_name    = cfg.service_name
      pod_regex       = cfg.pod_regex
      container       = cfg.container
      aws_tag_project = coalesce(cfg.aws_tag_project, var.project)
    }
  }

  # Panels 2 (5xx ratio) and 3 (latency) of dashboards/red.json get threshold lines from var.red_thresholds,
  # matched by panel id so a title edit in the JSON cannot detach them. try() leaves every other panel unchanged.
  threshold_panels = {
    for key, d in local.dashboards : key => [
      for p in try(local.templates[d.name].panels, []) : merge(p, try({
        "2" = {
          fieldConfig = {
            defaults = merge(p.fieldConfig.defaults, {
              custom     = merge(p.fieldConfig.defaults.custom, { thresholdsStyle = { mode = "line" } })
              thresholds = { mode = "absolute", steps = [{ color = "green", value = null }, { color = "red", value = var.red_thresholds.error_ratio }] }
            })
            overrides = p.fieldConfig.overrides
          }
        }
        "3" = {
          fieldConfig = {
            defaults = merge(p.fieldConfig.defaults, {
              custom     = merge(p.fieldConfig.defaults.custom, { thresholdsStyle = { mode = "line" } })
              thresholds = { mode = "absolute", steps = [{ color = "green", value = null }, { color = "red", value = var.red_thresholds.p95_seconds }] }
            })
            overrides = p.fieldConfig.overrides
          }
        }
      }[d.name == "red" ? tostring(p.id) : ""], {}))
    ]
  }

  # min_interval stamps the panel and each target of every panel that has targets, including panels nested in rows.
  rendered = {
    for key, d in local.dashboards : key => jsonencode(merge(
      { for k, v in local.templates[d.name] : k => v if !contains(["id", "version", "templating", "panels"], k) },
      {
        uid   = "${var.project}-${d.env}-${d.name}"
        title = coalesce(try(var.dashboard_overrides[d.name].title, null), "${var.project} ${d.env} - ${local.default_titles[d.name]}")
        tags  = [var.project, d.env]
        templating = {
          list = [
            for t in try(local.templates[d.name].templating.list, []) : merge(t, try({
              for name, value in local.constants[d.env] : name => {
                query   = value
                current = { text = value, value = value }
                options = [{ text = value, value = value, selected = true }]
              }
            }[t.name], {}))
          ]
        }
        panels = [
          for p in local.threshold_panels[key] : merge(
            p,
            { for k, v in { interval = var.min_interval, targets = [for t in try(p.targets, []) : merge(t, { interval = var.min_interval })] } :
            k => v if var.min_interval != null && length(try(p.targets, [])) > 0 },
            try({
              panels = [
                for c in p.panels : merge(
                  c,
                  { for k, v in { interval = var.min_interval, targets = [for t in try(c.targets, []) : merge(t, { interval = var.min_interval })] } :
                  k => v if var.min_interval != null && length(try(c.targets, [])) > 0 },
                )
              ]
            }, {}),
          )
        ]
      },
    ))
  }
}
