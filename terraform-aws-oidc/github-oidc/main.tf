module "provider" {
  source = "../provider"

  url                    = var.url
  client_id_list         = var.client_id_list
  additional_thumbprints = var.additional_thumbprints
  create_provider        = var.create_provider
}
