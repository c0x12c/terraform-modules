# --- S3 locations -------------------------------------------------------------

resource "aws_datasync_location_s3" "source" {
  count = var.source_s3 != null ? 1 : 0

  s3_bucket_arn    = var.source_s3.s3_bucket_arn
  subdirectory     = var.source_s3.subdirectory
  s3_storage_class = var.source_s3.s3_storage_class

  s3_config {
    bucket_access_role_arn = coalesce(var.source_s3.bucket_access_role_arn, try(aws_iam_role.s3_access["src"].arn, null))
  }

  tags = var.tags
}

resource "aws_datasync_location_s3" "destination" {
  count = var.destination_s3 != null ? 1 : 0

  s3_bucket_arn    = var.destination_s3.s3_bucket_arn
  subdirectory     = var.destination_s3.subdirectory
  s3_storage_class = var.destination_s3.s3_storage_class

  s3_config {
    bucket_access_role_arn = coalesce(var.destination_s3.bucket_access_role_arn, try(aws_iam_role.s3_access["dst"].arn, null))
  }

  tags = var.tags
}

# --- Object-storage locations -------------------------------------------------

resource "aws_datasync_location_object_storage" "source" {
  count = var.source_object_storage != null ? 1 : 0

  server_hostname = var.source_object_storage.server_hostname
  bucket_name     = var.source_object_storage.bucket_name
  agent_arns      = var.source_object_storage.agent_arns
  subdirectory    = var.source_object_storage.subdirectory
  access_key      = var.source_object_storage.access_key
  secret_key      = var.source_object_storage.secret_key
  server_protocol = var.source_object_storage.server_protocol
  server_port     = var.source_object_storage.server_port

  tags = var.tags
}

resource "aws_datasync_location_object_storage" "destination" {
  count = var.destination_object_storage != null ? 1 : 0

  server_hostname = var.destination_object_storage.server_hostname
  bucket_name     = var.destination_object_storage.bucket_name
  agent_arns      = var.destination_object_storage.agent_arns
  subdirectory    = var.destination_object_storage.subdirectory
  access_key      = var.destination_object_storage.access_key
  secret_key      = var.destination_object_storage.secret_key
  server_protocol = var.destination_object_storage.server_protocol
  server_port     = var.destination_object_storage.server_port

  tags = var.tags
}
