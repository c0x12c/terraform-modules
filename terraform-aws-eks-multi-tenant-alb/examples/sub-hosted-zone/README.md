# Sub-hosted-zone, apex SAN, helm-first ingresses

Full tenant setup: the module creates one Route53 sub-zone per tenant, writes the NS
delegation into the parent zone, issues a tenant certificate in us-west-2 (apex +
wildcard SAN) and the same certificate in us-east-1 for CloudFront, and points the
tenant apex at an external CloudFront distribution. Service ingresses are left off
because the service Helm charts render them with the ALB's ingress group name.
