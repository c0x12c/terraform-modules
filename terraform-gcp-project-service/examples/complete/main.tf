module "project_service" {
  source = "../../"

  project_id = "example-project"
  services = [
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "compute.googleapis.com",
    "autoscaling.googleapis.com",
    "dns.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "redis.googleapis.com",
    "cloudscheduler.googleapis.com",
    "servicenetworking.googleapis.com",
    "container.googleapis.com",
    "cloudtasks.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudbilling.googleapis.com",
    "apikeys.googleapis.com",
    "admin.googleapis.com",
    "artifactregistry.googleapis.com"
  ]
}
