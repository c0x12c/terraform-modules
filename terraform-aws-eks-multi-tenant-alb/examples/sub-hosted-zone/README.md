# Sub-hosted-zone, apex SAN, CloudFront cert, helm-first ingresses

Full tenant setup: the module creates one Route53 sub-zone per tenant, writes the NS
delegation into the parent zone, issues a tenant certificate in us-west-2 (for the ALB)
and a copy in us-east-1 (for CloudFront), and points the tenant apex at an external
CloudFront distribution. Service ingresses are left off because the service Helm charts
render them with the ALB's ingress group name.
