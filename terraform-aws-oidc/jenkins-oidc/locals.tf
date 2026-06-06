locals {
  default_oidc_policy_statement = [
    {
      effect = "Allow"
      actions = [
        "cloudfront:CreateInvalidation"
      ]
      resources = ["*"]
    },
    {
      effect = "Allow"
      actions = [
        "s3:ListAllMyBuckets",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:GetBucketLocation"
      ]
      resources = ["*"]
    },
    {
      effect = "Allow"
      actions = [
        "eks:DescribeCluster",
        "eks:ListClusters",
      ]
      resources = ["*"]
    },
    {
      effect = "Allow"
      actions = [
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:InitiateLayerUpload",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "ecr:DescribeRepositories",
        "ecr:GetAuthorizationToken"
      ]
      resources = ["*"]
    },
    {
      effect = "Allow"
      actions = [
        "ssm:PutParameter",
        "ssm:DeleteParameter",
        "ssm:GetParametersByPath",
        "ssm:GetParameters",
        "ssm:GetParameter",
        "ssm:DeleteParameters"
      ]
      resources = ["*"]
    }
  ]
}
