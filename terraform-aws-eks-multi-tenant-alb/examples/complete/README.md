# Complete example

One tenant (`acme`) with two services (`auth`, `rental`), served at `auth.acme.example.com` and
`rental.acme.example.com`. It needs an EKS cluster with the AWS Load Balancer Controller.

```bash
terraform init
terraform plan
```
