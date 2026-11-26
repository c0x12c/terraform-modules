resource "grafana_folder" "parent" {
  title                        = var.project
  uid                          = local.parent_folder_uid
  prevent_destroy_if_not_empty = true
}

resource "grafana_folder" "env" {
  for_each = var.environments

  title                        = each.key
  uid                          = local.env_folder_uids[each.key]
  parent_folder_uid            = grafana_folder.parent.uid
  prevent_destroy_if_not_empty = true
}

resource "grafana_dashboard" "this" {
  for_each = local.dashboards

  folder      = grafana_folder.env[each.value.env].uid
  config_json = local.rendered[each.key]
  overwrite   = true
}
