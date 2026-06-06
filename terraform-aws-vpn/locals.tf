locals {
  create_self_signed_cert = var.certificate_arn == null ? true : false
}
