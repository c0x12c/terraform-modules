locals {
  # Exactly-one-of validation counts, enforced by preconditions on the task.
  source_count = length([
    for v in [var.source_s3, var.source_object_storage, var.source_location_arn] : v if v != null
  ])
  destination_count = length([
    for v in [var.destination_s3, var.destination_object_storage, var.destination_location_arn] : v if v != null
  ])

  # Effective location ARNs, resolved from whichever input was provided.
  source_location_arn = try(coalesce(
    try(aws_datasync_location_s3.source[0].arn, null),
    try(aws_datasync_location_object_storage.source[0].arn, null),
    var.source_location_arn,
  ), null)

  destination_location_arn = try(coalesce(
    try(aws_datasync_location_s3.destination[0].arn, null),
    try(aws_datasync_location_object_storage.destination[0].arn, null),
    var.destination_location_arn,
  ), null)

  # S3 locations that need a module-created access role (arn not supplied).
  s3_role_targets = merge(
    var.source_s3 != null ? (var.source_s3.bucket_access_role_arn == null ? { src = var.source_s3.s3_bucket_arn } : {}) : {},
    var.destination_s3 != null ? (var.destination_s3.bucket_access_role_arn == null ? { dst = var.destination_s3.s3_bucket_arn } : {}) : {},
  )

  cloudwatch_log_group_arn = var.create_cloudwatch_log_group ? try(aws_cloudwatch_log_group.this[0].arn, null) : var.cloudwatch_log_group_arn
}
