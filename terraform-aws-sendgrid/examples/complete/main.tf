module "sendgrid" {
  source = "../../"

  api_keys = {
    "email-sending-service" = {
      name = "Email Sending Service"
      scopes = [
        "mail.send",
        "2fa_required",
        "sender_verification_eligible"
      ]
    }
  }
  dns_zone_id   = "zone-id"
  dns_zone_name = "zone-name"
}
