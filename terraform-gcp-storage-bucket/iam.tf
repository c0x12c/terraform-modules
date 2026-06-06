/**
`google_storage_bucket_iam_binding` updates the IAM policy to grant a role to a list of members.
This block grants the roles/storage.objectUser role to specified members, enabling them to read and write objects in the GCS bucket.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam#google_storage_bucket_iam_binding
 */
resource "google_storage_bucket_iam_binding" "users" {
  count = var.bucket_users != [] ? 1 : 0

  bucket  = google_storage_bucket.this.name
  role    = "roles/storage.objectUser"
  members = var.bucket_users
}

/**
`google_storage_bucket_iam_binding` updates the IAM policy to grant a role to a list of members.
This block grants the roles/storage.objectViewer role to specified members, allowing them to view objects in the GCS bucket.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam#google_storage_bucket_iam_binding
 */
resource "google_storage_bucket_iam_binding" "viewers" {
  count = var.bucket_viewers != [] ? 1 : 0

  bucket  = google_storage_bucket.this.name
  role    = "roles/storage.objectViewer"
  members = var.bucket_viewers
}

resource "google_storage_bucket_iam_member" "creator" {
  count = var.enable_creator_policy ? 1 : 0

  bucket = google_storage_bucket.this.name
  role   = "roles/storage.objectCreator"
  member = "group:cloud-storage-analytics@google.com"
}
