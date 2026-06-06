resource "time_sleep" "wait_for_aws_load_balancer_webhook_is_running" {
  depends_on = [
    helm_release.aws_load_balancer_controller
  ]
  create_duration = "30s"
}
