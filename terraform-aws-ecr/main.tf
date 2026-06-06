/*
aws_ecr_repository creates an Elastic Container Registry (ECR) repository for managing Docker images.
This block defines the repository’s name, mutability settings, image scanning, and tags.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
*/
resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = var.tags
}

/*
aws_ecr_lifecycle_policy_document defines the lifecycle rules for the ECR repository.
This data source provides structure to manage image retention within the repository.
It includes two rules: one to retain the last 50 images and another to remove untagged images older than one day.
*/
data "aws_ecr_lifecycle_policy_document" "this" {
  rule {
    priority    = 90
    description = "keep last 50 images"

    action {
      type = "expire"
    }

    selection {
      tag_status   = "any"
      count_type   = "imageCountMoreThan"
      count_number = 50
    }
  }

  rule {
    priority    = 10
    description = "remove untagged images"

    action {
      type = "expire"
    }

    selection {
      tag_status   = "untagged"
      count_type   = "sinceImagePushed"
      count_number = 1
      count_unit   = "days"
    }
  }
}

/*
aws_ecr_lifecycle_policy applies the lifecycle policy to the specified ECR repository.
It references the JSON output of the lifecycle policy document defined above.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy
*/
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = data.aws_ecr_lifecycle_policy_document.this.json
}


# https://registry.terraform.io/providers/hashicorp/aws/5.83.1/docs/resources/ecr_registry_scanning_configuration
resource "aws_ecr_registry_scanning_configuration" "this" {
  count = var.custom_ecr_scanning ? 1 : 0

  scan_type = var.scan_type

  rule {
    scan_frequency = var.scan_frequency
    repository_filter {
      # currently only WILDCARD is supported
      filter_type = "WILDCARD"
      filter      = var.name
    }
  }
}
