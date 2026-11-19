# Complete example

Manages two us-west-2 quotas (Fargate On-Demand vCPUs and EC2 On-Demand Standard vCPUs)
and adopts them with an `import` block, so the first apply submits no increase request
when the values match what the account applies today.

```bash
terraform init
terraform plan   # expect: 2 to import, 0 to add, 0 to change, 0 to destroy
```

The values are examples. Read your account's applied values first with
`aws service-quotas get-service-quota --service-code <code> --quota-code <code>` and set
`value` to them, or the apply submits an increase request.
