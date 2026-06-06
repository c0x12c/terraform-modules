output "bucket_url" {
  description = "The URI of the created resource."
  value       = join("", ["https://storage.googleapis.com/", split("//", google_storage_bucket.this.url)[1]])
}

output "bucket_name" {
  description = "The Bucket name of the created resource."
  value       = split("//", google_storage_bucket.this.url)[1]
}
