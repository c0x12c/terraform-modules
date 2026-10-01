# Wildcard tenant example

Every tenant is served by one wildcard host per service: `*.auth.example.com` and `*.rental.example.com`.
The module creates one wildcard certificate and one wildcard DNS record per service, so a new tenant
needs no Terraform change. The backend reads the tenant from the first label of `Host` and rejects
unknown tenants. It needs an EKS cluster with the AWS Load Balancer Controller.

```bash
terraform init
terraform plan
```
