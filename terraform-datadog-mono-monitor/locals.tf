locals {
  # HTTP check
  default_http_check_monitors = {
    http_check = {
      priority_level = 2
      title_tags     = "[HTTP Check]"
      title          = "URLs are not healthy"

      type           = "service check"
      query_template = "\"http.can_connect\".over(\"env:${var.environment}\").by(\"url\").last(2).count_by_status()"

      threshold_critical = 1
      ok                 = 1
      renotify_interval  = 60
    }
  }

  # K8S monitor
  default_pod_monitors = merge({
    crash_loop_back_off = local.crash_loop_back_off,
    image_pull_back_off = local.image_pull_back_off,
    failed              = local.failed
  })

  crash_loop_back_off = {
    priority_level = 2
    title_tags     = "[CrashLoopBackOff Pod]"
    title          = "Pod {{pod_name.name}} is CrashloopBackOff on namespace"

    query_template = "max($${timeframe}):default_zero(max:kubernetes_state.container.status_report.count.waiting{kube_cluster_name:${var.cluster_name}, reason:crashloopbackoff, kube_namespace:${var.namespace_regex}} by {kube_cluster_name, kube_namespace, pod_name}) >= $${threshold_critical}"
    query_args = {
      timeframe = "last_5m"
    }

    threshold_critical          = 1
    threshold_critical_recovery = 0
    renotify_interval           = 60
  }

  image_pull_back_off = {
    priority_level = 2
    title_tags     = "[ImagePullBackOff Pod]"
    title          = "Pod {{pod_name.name}} is ImagePullBackOff on namespace"

    query_template = "max($${timeframe}):default_zero(max:kubernetes_state.container.status_report.count.waiting{kube_cluster_name:${var.cluster_name}, reason:imagepullbackoff, kube_namespace:${var.namespace_regex}} by {kube_cluster_name, kube_namespace, pod_name}) >= $${threshold_critical}"
    query_args = {
      timeframe = "last_5m"
    }

    threshold_critical          = 1
    threshold_critical_recovery = 0
    renotify_interval           = 60
  }

  failed = {
    priority_level = 2
    title_tags     = "[Failed Pod]"
    title          = "Pod {{pod_name.name}} is Failed on namespace"

    query_template = "max($${timeframe}):default_zero(max:kubernetes_state.container.status_report.count.waiting{kube_cluster_name:${var.cluster_name}, reason:failed, kube_namespace:${var.namespace_regex}} by {kube_cluster_name, kube_namespace, pod_name}) >= $${threshold_critical}"
    query_args = {
      timeframe = "last_5m"
    }

    threshold_critical          = 1
    threshold_critical_recovery = 0
    renotify_interval           = 60
  }
}
