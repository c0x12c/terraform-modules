locals {
  # Resource monitor
  default_pod_monitors = merge({
    restart = local.restart
  })

  restart = {
    priority_level = 2
    title_tags     = "[Service Restarts]"
    title          = "Service ${var.service_name} restarted"

    query_template = "change(max($${timeframe}),$${timeframe}):sum:kubernetes.containers.restarts{kube_cluster_name:${var.cluster_name}, kube_service:${var.service_name}, kube_container_name:$${kube_container_name}} by {kube_cluster_name,pod_name} >= $${threshold_critical}"
    query_args = {
      timeframe           = "last_5m"
      kube_container_name = var.overwrite_container_name != null ? var.overwrite_container_name : var.service_name
    }

    on_missing_data = var.restart_on_missing_data

    threshold_critical          = 1
    threshold_critical_recovery = 0.5
    renotify_interval           = 60
  }

  default_cpu_monitors = {
    cpu = {
      priority_level = 3
      title_tags     = "[High CPU Utilization]"
      title          = "Service ${var.service_name} CPU utilization is high"

      query_template = "avg($${timeframe}):(avg:kubernetes.cpu.usage.total{kube_service:${var.service_name}, kube_container_name:$${kube_container_name}, kube_cluster_name:${var.cluster_name}} / avg:kubernetes.cpu.limits{kube_service:${var.service_name}, kube_container_name:$${kube_container_name}, kube_cluster_name:${var.cluster_name}}) / 10e6 > $${threshold_critical}"
      query_args = {
        timeframe           = "last_5m"
        kube_container_name = var.overwrite_container_name != null ? var.overwrite_container_name : var.service_name
      }

      threshold_critical          = 80
      threshold_critical_recovery = 70
      renotify_interval           = 60
    }
  }

  default_memory_monitors = {
    memory = {
      priority_level = 3
      title_tags     = "[High Memory Utilization]"
      title          = "Service ${var.service_name} Memory utilization is high"

      query_template = "avg($${timeframe}):(avg:kubernetes.memory.usage{kube_service:${var.service_name}, kube_container_name:$${kube_container_name}, kube_cluster_name:${var.cluster_name}} / avg:kubernetes.memory.limits{kube_service:${var.service_name}, kube_container_name:$${kube_container_name}, kube_cluster_name:${var.cluster_name}}) * 100 > $${threshold_critical}"
      query_args = {
        timeframe           = "last_5m"
        kube_container_name = var.overwrite_container_name != null ? var.overwrite_container_name : var.service_name
      }

      threshold_critical          = 80
      threshold_critical_recovery = 70
      renotify_interval           = 60
    }
  }

  # service monitor
  default_service_monitors = merge({
    p95         = local.p95,
    request_hit = local.request_hit,
    error_hit   = local.error_hit
  })

  p95 = {
    priority_level = 3
    title_tags     = "[High P95 Latency]"
    title          = "Service ${var.service_name} P95 latency is high"

    query_template = "percentile($${timeframe}):p95:$${metric}{env:${var.environment},service:${var.service_name}} by {resource_name} > $${threshold_critical}"
    query_args = {
      timeframe = "last_5m"
      metric    = local.p95_metric
    }

    threshold_critical          = 1
    threshold_critical_recovery = 0.9
    renotify_interval           = 60
  }

  request_hit = {
    priority_level = 3
    title_tags     = "[High Request Hits]"
    title          = "Service ${var.service_name} Request Hits is high"

    query_template = "sum($${timeframe}):sum:$${metric}{env:${var.environment},service:${var.service_name}}.as_count() > $${threshold_critical}"
    query_args = {
      timeframe = "last_5m"
      metric    = local.request_hit_metric
    }

    threshold_critical          = 10000
    threshold_critical_recovery = 8000
    renotify_interval           = 60
  }

  error_hit = {
    priority_level = 3
    title_tags     = "[High Error Hits]"
    title          = "Service ${var.service_name} Error Hits is high"

    query_template = "sum($${timeframe}):sum:$${metric}{env:${var.environment},service:${var.service_name}}.as_count() > $${threshold_critical}"
    query_args = {
      timeframe = "last_5m"
      metric    = local.error_hit_metric
    }

    threshold_critical          = 1
    threshold_critical_recovery = 0
    renotify_interval           = 60
  }

  p95_metric         = var.p95_metric
  request_hit_metric = var.request_hit_metric
  error_hit_metric   = var.error_hit_metric
}
