resource "aws_instance" "this" {
  ami           = var.source_ami
  instance_type = var.source_instance_type

  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = var.security_group_ids

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens   = var.http_tokens
    http_endpoint = var.http_endpoint
  }

  user_data_replace_on_change = true
  user_data                   = base64encode(templatefile("${path.module}/scripts/setup-environment.tmpl", { TERRAFORM_VERSION = var.terraform_version }))

  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}

resource "aws_ami_from_instance" "this" {
  name               = var.custom_ami_name
  source_instance_id = aws_instance.this.id

  depends_on = [aws_instance.this]
}

resource "aws_launch_template" "this" {
  name        = "github_runner_launch_template"
  description = "Launch Template for GitHub Runners"

  image_id               = aws_ami_from_instance.this.id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(templatefile("${path.module}/scripts/actions-runner-setup.tmpl", { GITHUB_ORG = var.org_name, GITHUB_ACTIONS_RUNNER_REGISTRATION_TOKEN = var.github_actions_runner_registration_token, RUNNER_VERSION = var.runner_version, RUNNER_HOME = var.runner_home, RUNNER_LABELS = var.runner_labels }))

  update_default_version = var.update_default_launch_template_version

  tags = {
    Name = "github_runner"
  }

  depends_on = [aws_ami_from_instance.this]
}

resource "aws_autoscaling_group" "this" {
  name                      = "github_runners_autoscaling_group"
  health_check_type         = "EC2"
  health_check_grace_period = var.health_check_grace_period
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  vpc_zone_identifier       = var.subnet_ids
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}
