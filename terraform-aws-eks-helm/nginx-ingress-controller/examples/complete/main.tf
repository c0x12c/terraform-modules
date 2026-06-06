module "example" {
  source = "../.."

  network_cidr = "10.1.0.0/16"

  nginx_cpu    = "100m"
  nginx_memory = "90Mi"

  replicas     = 1
  min_replicas = 1
  max_replicas = 3
}
