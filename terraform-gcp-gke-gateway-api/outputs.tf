output "ext_gateway_address" {
  description = "The external IP address of the external gateway resource."
  value       = data.kubernetes_resource.external_gateway.object.status.addresses[0].value
}
