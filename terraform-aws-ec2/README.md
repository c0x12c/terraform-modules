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
  source  = "terraform.c0x12c.com/c0x12c/ec2/aws"
  version = "1.0.0"

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
  source  = "terraform.c0x12c.com/c0x12c/ec2/aws"
  version = "1.0.0"

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
  source  = "terraform.c0x12c.com/c0x12c/ec2/aws"
  version = "1.0.0"

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
  source  = "terraform.c0x12c.com/c0x12c/ec2/aws"
  version = "1.0.0"

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
  source  = "terraform.c0x12c.com/c0x12c/ec2/aws"
  version = "1.0.0"

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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | ID of AMI to use for the instance | `string` | n/a | yes |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to associate a public IP address with an instance in a VPC | `bool` | `false` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | AZ to start the instance in | `string` | `null` | no |
| <a name="input_create_eip"></a> [create\_eip](#input\_create\_eip) | Whether to create an Elastic IP for the instance | `bool` | `false` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| <a name="input_ebs_block_devices"></a> [ebs\_block\_devices](#input\_ebs\_block\_devices) | Additional EBS block devices to attach to the instance.<br/>Each block device should include:<br/>- device\_name: The name of the device to mount<br/>- volume\_type: The type of volume (gp2, gp3, io1, io2, st1, sc1)<br/>- volume\_size: The size of the volume in gigabytes<br/>- iops: The amount of provisioned IOPS (only for io1, io2, gp3)<br/>- throughput: The throughput to provision for gp3 volumes<br/>- encrypted: Whether to enable volume encryption<br/>- kms\_key\_id: The ARN of the AWS KMS key to use for encryption<br/>- snapshot\_id: The Snapshot ID to mount<br/>- delete\_on\_termination: Whether the volume should be destroyed on instance termination<br/>- tags: A map of tags to assign to the device | `list(any)` | `[]` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized | `bool` | `true` | no |
| <a name="input_eip_tags"></a> [eip\_tags](#input\_eip\_tags) | A map of tags to assign to the Elastic IP | `map(string)` | `{}` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM Instance Profile to launch the instance with | `string` | `null` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances | `string` | `"stop"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of instance to start | `string` | `"t3.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key name of the Key Pair to use for the instance | `string` | `null` | no |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | Customize the metadata options of the instance.<br/>Available options:<br/>- http\_endpoint: Whether the metadata service is available (enabled or disabled)<br/>- http\_tokens: Whether or not the metadata service requires session tokens (optional or required)<br/>- http\_put\_response\_hop\_limit: The desired HTTP PUT response hop limit for instance metadata requests<br/>- instance\_metadata\_tags: Enables or disables access to instance tags from the instance metadata service | `any` | `null` | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on EC2 instance created | `string` | n/a | yes |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | Customize network interfaces to be attached at instance boot time.<br/>Each network interface should include:<br/>- device\_index: The integer index of the network interface attachment<br/>- network\_interface\_id: The ID of the network interface to attach<br/>- delete\_on\_termination: Whether or not to delete the network interface on instance termination | `list(any)` | `[]` | no |
| <a name="input_root_block_device"></a> [root\_block\_device](#input\_root\_block\_device) | Customize details about the root block device of the instance.<br/>Available options:<br/>- volume\_type: The type of volume (gp2, gp3, io1, io2, st1, sc1)<br/>- volume\_size: The size of the volume in gigabytes<br/>- iops: The amount of provisioned IOPS (only for io1, io2, gp3)<br/>- throughput: The throughput to provision for gp3 volumes<br/>- encrypted: Whether to enable volume encryption<br/>- kms\_key\_id: The ARN of the AWS KMS key to use for encryption<br/>- delete\_on\_termination: Whether the volume should be destroyed on instance termination<br/>- tags: A map of tags to assign to the device | `any` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A list of security group IDs to associate with | `list(string)` | `[]` | no |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | Controls if traffic is routed to the instance when the destination address does not match the instance | `bool` | `true` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The VPC Subnet ID to launch in | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the instance | `map(string)` | `{}` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host | `string` | `"default"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to provide when launching the instance | `string` | `null` | no |
| <a name="input_user_data_base64"></a> [user\_data\_base64](#input\_user\_data\_base64) | Can be used instead of user\_data to pass base64-encoded binary data directly | `string` | `null` | no |
| <a name="input_volume_tags"></a> [volume\_tags](#input\_volume\_tags) | A map of tags to assign to the devices created by the instance at launch time | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the instance |
| <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone) | The availability zone of the instance |
| <a name="output_eip_id"></a> [eip\_id](#output\_eip\_id) | Contains the EIP allocation ID |
| <a name="output_eip_public_dns"></a> [eip\_public\_dns](#output\_eip\_public\_dns) | Public DNS associated with the Elastic IP address |
| <a name="output_eip_public_ip"></a> [eip\_public\_ip](#output\_eip\_public\_ip) | Contains the public IP address |
| <a name="output_id"></a> [id](#output\_id) | The ID of the instance |
| <a name="output_instance_state"></a> [instance\_state](#output\_instance\_state) | The state of the instance |
| <a name="output_primary_network_interface_id"></a> [primary\_network\_interface\_id](#output\_primary\_network\_interface\_id) | The ID of the instance's primary network interface |
| <a name="output_private_dns"></a> [private\_dns](#output\_private\_dns) | The private DNS name assigned to the instance |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | The private IP address assigned to the instance |
| <a name="output_public_dns"></a> [public\_dns](#output\_public\_dns) | The public DNS name assigned to the instance |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | The public IP address assigned to the instance |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags |
<!-- END_TF_DOCS -->

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
