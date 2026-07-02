module "devlake" {
  source = "../../"

  namespace     = "devlake"
  chart_version = "1.0.2"
  hostname      = "devlake.example.com"

  enable_grafana         = true
  grafana_admin_password = "REPLACE_ME"

  ingress_class_name = "alb"
  ingress_annotations = {
    "alb.ingress.kubernetes.io/scheme"           = "internal"
    "alb.ingress.kubernetes.io/group.name"       = "internal"
    "alb.ingress.kubernetes.io/target-type"      = "ip"
    "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTPS\": 443}]"
    "alb.ingress.kubernetes.io/healthcheck-path" = "/health/"
  }

  encryption_secret   = "REPLACE_WITH_A_GENERATED_SECRET"
  mysql_password      = "REPLACE_ME"
  mysql_root_password = "REPLACE_ME"
}
