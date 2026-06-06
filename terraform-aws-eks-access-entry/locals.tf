locals {
  namespaces = { for namespace in var.custom_namespaces : namespace => namespace }
}
