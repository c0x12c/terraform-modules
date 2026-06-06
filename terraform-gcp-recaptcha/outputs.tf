output "android_key_id" {
  value = element(split("/", google_recaptcha_enterprise_key.android.id), length(split("/", google_recaptcha_enterprise_key.android.id)) - 1)
}

output "ios_key_id" {
  value = element(split("/", google_recaptcha_enterprise_key.ios.id), length(split("/", google_recaptcha_enterprise_key.ios.id)) - 1)
}
