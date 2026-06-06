module "docker_repository" {
  source = "../../"

  format        = "DOCKER"
  location      = "us-west1"
  project_id    = "example-project"
  repository_id = "service-image"

  docker_config = {
    immutable_tags = true
  }

  cleanup_policies = {
    keep_1_month = {
      action = "DELETE"
      condition = {
        older_than_days = "30d"
      }
    }
  }
}
