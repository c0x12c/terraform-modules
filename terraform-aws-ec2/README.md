# AWS EC2 Instance Terraform Module

Terraform module to provision AWS EC2 instances with comprehensive configuration options.

## Features

- ✅ EC2 instance provisioning with customizable parameters
- ✅ Root and additional EBS volume configuration
- ✅ Elastic IP support
- ✅ Custom network interface attachment
- ✅ IMDSv2 metadata security enforcement
- ✅ User data script support
- ✅ Comprehensive tagging
- ✅ Security group association
- ✅ IAM instance profile support

## Usage

### Basic Example

```hcl
module "ec2" {
  source = "git::https://github.com/c0x12c/terraform-modules.git//terraform-aws-ec2?ref=terraform-aws-ec2/v1.0.0"

  name               = "my-instance"
  ami                = "ami-0c55b159cbfafe1f0"
  instance_type      = "t3.micro"
  subnet_id          = "subnet-12345678"
  security_group_ids = ["sg-12345678"]
  key_name           = "my-key-pair"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Advanced Example with EBS Volumes

```hcl
module "ec2_with_volumes" {
  source = "git::https://github.com/c0x12c/terraform-modules.git//terraform-aws-ec2?ref=terraform-aws-ec2/v1.0.0"

  name               = "app-server"
  ami                = "ami-0c55b159cbfafe1f0"
  instance_type      = "t3.medium"
  subnet_id          = "subnet-12345678"
  security_group_ids = ["sg-12345678"]
  key_name           = "my-key-pair"

  root_block_device = {
    volume_type           = "gp3"
    volume_size           = 30
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    delete_on_termination = true
  }

  ebs_block_devices = [
    {
      device_name           = "/dev/sdf"
      volume_type           = "gp3"
      volume_size           = 100
      encrypted             = true
      delete_on_termination = true
    }
  ]

  tags = {
    Environment = "production"
    Application = "web-server"
  }
}
```

### Instance with Elastic IP

```hcl
module "ec2_with_eip" {
  source = "git::https://github.com/c0x12c/terraform-modules.git//terraform-aws-ec2?ref=terraform-aws-ec2/v1.0.0"

  name                        = "bastion-host"
  ami                         = "ami-0c55b159cbfafe1f0"
  instance_type               = "t3.micro"
  subnet_id                   = "subnet-12345678"
  security_group_ids          = ["sg-12345678"]
  key_name                    = "my-key-pair"
  associate_public_ip_address = true

  create_eip = true

  tags = {
    Environment = "production"
    Purpose     = "bastion"
  }
}
```

### Instance with User Data

```hcl
module "ec2_with_userdata" {
  source = "git::https://github.com/c0x12c/terraform-modules.git//terraform-aws-ec2?ref=terraform-aws-ec2/v1.0.0"

  name               = "web-server"
  ami                = "ami-0c55b159cbfafe1f0"
  instance_type      = "t3.small"
  subnet_id          = "subnet-12345678"
  security_group_ids = ["sg-12345678"]
  key_name           = "my-key-pair"
  user_data          = file("${path.module}/user_data.sh")

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tags = {
    Environment = "production"
  }
}
```

### Instance with IAM Role

```hcl
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}

module "ec2_with_iam" {
  source = "git::https://github.com/c0x12c/terraform-modules.git//terraform-aws-ec2?ref=terraform-aws-ec2/v1.0.0"

  name                 = "app-server"
  ami                  = "ami-0c55b159cbfafe1f0"
  instance_type        = "t3.medium"
  subnet_id            = "subnet-12345678"
  security_group_ids   = ["sg-12345678"]
  key_name             = "my-key-pair"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Environment = "production"
  }
}
```

## Examples

- [Ubuntu Desktop Server](./examples/ubuntu-desktop) - Complete example of hosting Ubuntu desktop environment with RDP/VNC access

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.8 |
| aws | >= 5.75 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.75 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name to be used on EC2 instance created | `string` | n/a | yes |
| ami | ID of AMI to use for the instance | `string` | n/a | yes |
| instance_type | The type of instance to start | `string` | `"t3.micro"` | no |
| subnet_id | The VPC Subnet ID to launch in | `string` | n/a | yes |
| security_group_ids | A list of security group IDs to associate with | `list(string)` | `[]` | no |
| key_name | Key name of the Key Pair to use for the instance | `string` | `null` | no |
| iam_instance_profile | IAM Instance Profile to launch the instance with | `string` | `null` | no |
| associate_public_ip_address | Whether to associate a public IP address with an instance in a VPC | `bool` | `false` | no |
| user_data | The user data to provide when launching the instance | `string` | `null` | no |
| user_data_base64 | Can be used instead of user_data to pass base64-encoded binary data directly | `string` | `null` | no |
| availability_zone | AZ to start the instance in | `string` | `null` | no |
| tenancy | The tenancy of the instance (if the instance is running in a VPC) | `string` | `"default"` | no |
| ebs_optimized | If true, the launched EC2 instance will be EBS-optimized | `bool` | `true` | no |
| monitoring | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `false` | no |
| source_dest_check | Controls if traffic is routed to the instance when the destination address does not match the instance | `bool` | `true` | no |
| disable_api_termination | If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| instance_initiated_shutdown_behavior | Shutdown behavior for the instance | `string` | `"stop"` | no |
| root_block_device | Customize details about the root block device of the instance | `any` | `null` | no |
| ebs_block_devices | Additional EBS block devices to attach to the instance | `list(any)` | `[]` | no |
| metadata_options | Customize the metadata options of the instance | `any` | `null` | no |
| network_interfaces | Customize network interfaces to be attached at instance boot time | `list(any)` | `[]` | no |
| create_eip | Whether to create an Elastic IP for the instance | `bool` | `false` | no |
| eip_tags | A map of tags to assign to the Elastic IP | `map(string)` | `{}` | no |
| tags | A map of tags to assign to the instance | `map(string)` | `{}` | no |
| volume_tags | A map of tags to assign to the devices created by the instance at launch time | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the instance |
| arn | The ARN of the instance |
| instance_state | The state of the instance |
| public_ip | The public IP address assigned to the instance |
| private_ip | The private IP address assigned to the instance |
| public_dns | The public DNS name assigned to the instance |
| private_dns | The private DNS name assigned to the instance |
| primary_network_interface_id | The ID of the instance's primary network interface |
| availability_zone | The availability zone of the instance |
| eip_id | Contains the EIP allocation ID |
| eip_public_ip | Contains the public IP address of the EIP |
| eip_public_dns | Public DNS associated with the Elastic IP address |
| tags_all | A map of tags assigned to the resource |

## Instance Types

Common instance types and their use cases:

| Type | vCPUs | Memory | Use Case |
|------|-------|--------|----------|
| t3.micro | 2 | 1 GB | Minimal workloads, testing |
| t3.small | 2 | 2 GB | Low traffic applications |
| t3.medium | 2 | 4 GB | Small databases, dev environments |
| t3.large | 2 | 8 GB | Medium applications |
| t3.xlarge | 4 | 16 GB | Production applications |
| m5.large | 2 | 8 GB | Balanced workloads |
| m5.xlarge | 4 | 16 GB | General purpose production |
| c5.large | 2 | 4 GB | Compute-intensive |
| r5.large | 2 | 16 GB | Memory-intensive |

## EBS Volume Types

| Type | IOPS | Throughput | Use Case |
|------|------|------------|----------|
| gp3 | 3,000-16,000 | 125-1,000 MB/s | General purpose (recommended) |
| gp2 | 100-16,000 | Up to 250 MB/s | General purpose (legacy) |
| io1 | 100-64,000 | Up to 1,000 MB/s | High performance |
| io2 | 100-64,000 | Up to 1,000 MB/s | High performance, durability |
| st1 | 500 | Up to 500 MB/s | Throughput-optimized HDD |
| sc1 | 250 | Up to 250 MB/s | Cold HDD (infrequent access) |

## Security Best Practices

1. **IMDSv2**: Enable IMDSv2 by setting `metadata_options.http_tokens = "required"`
2. **Encryption**: Enable EBS encryption for all volumes
3. **Termination Protection**: Enable for production instances
4. **IAM Roles**: Use IAM instance profiles instead of access keys
5. **Security Groups**: Restrict inbound traffic to specific sources
6. **Key Pairs**: Use SSH key pairs for secure access
7. **Monitoring**: Enable detailed monitoring for production workloads
8. **Tags**: Use comprehensive tagging for cost tracking and governance

## License

MIT

## Authors

Maintained by the Spartans Team
