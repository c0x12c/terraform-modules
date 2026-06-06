# GKE Ingress Terraform module

This Terraform module provisions a Google Kubernetes Engine (GKE) Ingress configurable options.

This module will create the components below:

- GCP Public IP.
- A Security Policy defines an IP blacklist or whitelist that protects load balanced Google Cloud services by denying or
  permitting traffic from specified IP ranges.

## Usage

### Create GKE Ingress

```hcl
module "gke_ingress" {
  source  = "github.com/spartan-stratos/terraform-modules//gcp/gke-ingress?ref=v0.1.5"

  project_id = "example-project"
  gke_ingress_services = {
    service-1 = {
      rate_limit = {
        limit_5_requests_per_hour_on_ip = {
          priority       = "1000"
          count          = "5"
          interval_sec   = "3600"
          expression     = "request.path.matches(\"/api/oauth/send-code\")"
          preview        = true
          enforce_on_key = "IP"
        }
      }
    },
    service-2 = {
      rate_limit = {
        limit_5_requests_per_hour_on_ip = {
          priority       = "1000"
          count          = "5"
          interval_sec   = "3600"
          expression     = "request.path.matches(\"/api/oauth/send-code\")"
          preview        = false
          enforce_on_key = "IP"
        }
      }
    }
  }
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version   |
|---------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | \>= 1.9.8 |
| <a name="requirement_google"></a> [google](#requirement\_google)          | \>= 6.12  |

## Providers

| Name                                                       | Version  |
|------------------------------------------------------------|----------|
| <a name="provider_google"></a> [google](#provider\_google) | \>= 6.12 |

## Modules

No modules.

## Resources

| Name                                                                                                                                              | Type     |
|---------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [google_compute_global_address.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address)       | resource |
| [google_compute_security_policy.throttle](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_security_policy) | resource |

## Inputs

| Name                                                                                               | Description                                     | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | Default | Required |
|----------------------------------------------------------------------------------------------------|-------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_gke_ingress_services"></a> [gke\_ingress\_services](#input\_gke\_ingress\_services) | The list of services to expose via GKE ingress. | <pre>map(object({<br/>    rate_limit = map(object({<br/>      priority       = string # The priority of the rate limit rule.<br/>      count          = string # The number of requests allowed within the specified interval.<br/>      interval_sec   = string # The time interval in seconds for the rate limit rule.<br/>      expression     = string # A CEL expression to match requests for applying the rate limit.<br/>      preview        = bool   # Indicates whether the rate limit is in preview mode.<br/>      enforce_on_key = string # The key on which the rate limit is enforced (e.g., "IP").<br/>    }))<br/>  }))</pre> | `{}`    |    no    |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id)                                 | The project ID to manage the resources.         | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | n/a     |   yes    |

## Outputs

| Name                                                                                                                                         | Description                                                                                          |
|----------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| <a name="output_gke_ingress_lb_ip"></a> [gke\_ingress\_lb\_ip](#output\_gke\_ingress\_lb\_ip)                                                | A mapping of the service names to their corresponding Load Balancer IP addresses in the GKE cluster. |
| <a name="output_gke_ingress_throttle_policy_name"></a> [gke\_ingress\_throttle\_policy\_name](#output\_gke\_ingress\_throttle\_policy\_name) | A mapping of the service names to their associated throttle policy names.                            |

<!-- END_TF_DOCS -->
