module "example" {
  source = "../.."

  create_postgresql   = false
  postgresql_host     = "db_host"
  postgresql_db_name  = "db_name"
  postgresql_username = "db_username"
  postgresql_password = "db_password"

  create_ingress     = true
  ingress_class_name = "alb"
  ingress_hostname   = "keycloak.example.com"

  node_selector = {}
  tolerations   = []
}
