# Existing certificate example

One tenant (`acme`) with one service (`auth`), served at `acme-auth.example.com`. The host is one level
under the domain, so an existing `*.example.com` certificate covers it: the module creates no certificate
and no DNS record. Point the host at the `dns_name` output in the DNS system you use. It needs an EKS
cluster with the AWS Load Balancer Controller.

```bash
terraform init
terraform plan
```
