module "gke_autopilot" {
  source = "../../"

  cluster_name = "example"
  environment  = "dev"
  network      = "example"
  subnetwork   = "example"
  project_id   = "example"
  region       = "us-west1"
}
