# Ubuntu Desktop Server Example

This example demonstrates how to use the `terraform-aws-ec2` module to provision an EC2 instance running Ubuntu Desktop with XFCE desktop environment.

## Features

- **Ubuntu 22.04 LTS** with XFCE desktop environment
- **Remote Desktop Access** via RDP (port 3389) and VNC (port 5900)
- **Elastic IP** for consistent remote access
- **Pre-installed Software**:
  - Firefox Browser
  - Google Chrome
  - Visual Studio Code
  - Git, Vim, Curl, Wget
  - Essential development tools

## Prerequisites

- AWS credentials configured
- SSH key pair created in AWS
- Terraform >= 1.9.8

## Usage

1. Create a `terraform.tfvars` file:

```hcl
key_name = "your-ssh-key-name"
```

2. Initialize Terraform:

```bash
terraform init
```

3. Plan the deployment:

```bash
terraform plan
```

4. Apply the configuration:

```bash
terraform apply
```

5. Wait for the instance to be ready (approximately 5-10 minutes for desktop installation)

## Connecting to the Desktop

After deployment, you'll receive connection information in the outputs.

### RDP Connection (Recommended)

1. Get the Elastic IP from the output
2. Use any RDP client:
   - **Windows**: Remote Desktop Connection
   - **macOS**: Microsoft Remote Desktop
   - **Linux**: Remmina

3. Connection details:
   - **Host**: `<elastic_ip>:3389`
   - **Username**: `ubuntu`
   - **Password**: `ubuntu`

### VNC Connection

1. Use any VNC client (TigerVNC Viewer, RealVNC, etc.)
2. Connection details:
   - **Host**: `<elastic_ip>:5900`
   - **Password**: `ubuntu`

### SSH Connection

```bash
ssh -i <your-key.pem> ubuntu@<elastic_ip>
```

## Security Considerations

⚠️ **IMPORTANT**: This example uses a default password (`ubuntu`) for demonstration purposes only.

**After first login, immediately change the password:**

```bash
passwd
```

**Production Recommendations:**
1. Restrict security group ingress to specific IP addresses
2. Use strong passwords or SSH key authentication only
3. Enable AWS Systems Manager Session Manager instead of opening ports
4. Use AWS Client VPN or Site-to-Site VPN for secure access
5. Enable CloudWatch logging and monitoring
6. Apply AWS security best practices

## Cost Estimation

This example uses:
- **Instance Type**: t3.medium (~$0.0416/hour or ~$30/month)
- **EBS Volume**: 30 GB gp3 (~$2.40/month)
- **Elastic IP**: Free when attached to running instance

**Estimated Monthly Cost**: ~$32-35 USD (us-east-1 region)

## Customization

### Change Instance Type

Edit `main.tf` and modify the `instance_type` parameter:

```hcl
instance_type = "t3.large"  # More powerful
```

### Use Different Desktop Environment

Modify `user_data.sh` to install different desktop:

- **GNOME**: `apt-get install -y ubuntu-desktop`
- **KDE**: `apt-get install -y kubuntu-desktop`
- **MATE**: `apt-get install -y ubuntu-mate-desktop`

### Add Additional Software

Add installation commands to `user_data.sh`:

```bash
# Install Docker
apt-get install -y docker.io
usermod -aG docker ubuntu
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Troubleshooting

### Desktop not accessible after deployment

Wait 5-10 minutes after `terraform apply` completes. The user data script needs time to install the desktop environment.

Check installation progress:

```bash
ssh -i <your-key.pem> ubuntu@<elastic_ip>
tail -f /var/log/desktop-setup.log
```

### RDP connection refused

Verify security group allows inbound traffic on port 3389:

```bash
aws ec2 describe-security-groups --group-ids <security-group-id>
```

### VNC not working

Check VNC service status:

```bash
ssh -i <your-key.pem> ubuntu@<elastic_ip>
systemctl status vncserver@1.service
```

## Support

For issues with:
- **Terraform module**: Open an issue in the module repository
- **AWS resources**: Check AWS documentation
- **Desktop environment**: Refer to Ubuntu/XFCE documentation
