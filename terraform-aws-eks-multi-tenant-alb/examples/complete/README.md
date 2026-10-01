# Complete example

Two tenants (`acme`, `globex`) with two services (`auth`, `rental`), served at `auth.acme.example.com`,
`rental.acme.example.com`, `auth.globex.example.com` and `rental.globex.example.com`. The module creates
one wildcard certificate per tenant and one DNS record per host. It needs an EKS cluster with the AWS
Load Balancer Controller.

```bash
terraform init
terraform plan
```
