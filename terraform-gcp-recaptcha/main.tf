/**
This resource creates Google reCAPTCHA Enterprise keys for Android and iOS applications.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/recaptcha_enterprise_key
*/

resource "google_recaptcha_enterprise_key" "android" {
  display_name = "${var.project_id}-${var.environment}-android-recaptcha"

  android_settings {
    allow_all_package_names = var.allow_all_package_names
    allowed_package_names   = var.allowed_package_names
  }

  project = var.project_id

  labels = {
    environment = var.environment
  }
}

resource "google_recaptcha_enterprise_key" "ios" {
  display_name = "${var.project_id}-${var.environment}-ios-recaptcha"

  ios_settings {
    allow_all_bundle_ids = var.allow_all_bundle_ids
    allowed_bundle_ids   = var.allowed_bundle_ids
  }

  project = var.project_id

  labels = {
    environment = var.environment
  }
}
