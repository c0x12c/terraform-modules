/**
Provide a resource to manage a template of email.
https://registry.terraform.io/providers/Trois-Six/sendgrid/latest/docs/resources/template
 */
resource "sendgrid_template" "this" {
  for_each = var.sendgrid_transactional_templates

  name       = each.key
  generation = "dynamic"
}

/**
Provide a resource to manage a version of template.
https://registry.terraform.io/providers/anna-money/sendgrid/latest/docs/resources/template_version
 */
resource "sendgrid_template_version" "this" {
  for_each = var.sendgrid_transactional_templates

  name                   = each.key
  active                 = 1
  subject                = each.value.subject
  template_id            = sendgrid_template.this[each.key].id
  html_content           = each.value.content
  generate_plain_content = true
}
