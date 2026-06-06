output "api_keys" {
  value = {
    for key, value in sendgrid_api_key.this :
    key => value.api_key
  }
}

output "sendgrid_templates" {
  value = sendgrid_template.this
}
