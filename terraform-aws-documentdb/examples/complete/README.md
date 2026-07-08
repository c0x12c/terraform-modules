# Complete DocumentDB example

Provisions a single-instance Amazon DocumentDB cluster with TLS enabled, a security
group that allows an EKS worker security group and an office CIDR, and a Secrets Manager
secret holding the connection URI.

```bash
terraform init
terraform plan
```
