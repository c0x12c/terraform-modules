/*
aws_flow_log capture IP traffic for a specific network interface, subnet, or VPC
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log
 */
resource "aws_flow_log" "this" {
  count = var.create_flow_log ? 1 : 0

  iam_role_arn    = aws_iam_role.vpc-flow-logs-role[count.index].arn
  log_destination = aws_cloudwatch_log_group.this[count.index].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
 */
resource "aws_cloudwatch_log_group" "this" {
  count = var.create_flow_log ? 1 : 0

  name = "${var.name}-cloudwatch-log-group"
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
 */
resource "aws_iam_role" "vpc-flow-logs-role" {
  count = var.create_flow_log ? 1 : 0

  name               = "${var.name}-vpc-flow-logs-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
 */
resource "aws_iam_role_policy" "vpc-flow-logs-policy" {
  count = var.create_flow_log ? 1 : 0

  name   = "${var.name}-vpc-flow-logs-policy"
  role   = aws_iam_role.vpc-flow-logs-role[count.index].id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
