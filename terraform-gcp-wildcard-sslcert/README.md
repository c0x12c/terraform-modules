# Terraform Wildcard SSLCert Module

This Terraform module creates a cert map for a wildcard domain.

## Usage

```hcl
module "wildcard-sslcert" {
  source = "github.com/spartan-stratos/terraform-modules//gcp/wildcard-sslcert?ref=v0.1.4"
  domain = "example.com"
}
```

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_google"></a> [google](#requirement\_google)          | >= 6.12  |

## Providers

| Name                                                       | Version |
|------------------------------------------------------------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.12 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                        | Type        |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [google_certificate_manager_certificate.root_cert](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate)                          | resource    |
| [google_certificate_manager_certificate_map.wildcard_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate_map)               | resource    |
| [google_certificate_manager_certificate_map_entry.wildcard_entry](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate_map_entry) | resource    |
| [google_certificate_manager_dns_authorization.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_dns_authorization)                   | resource    |
| [google_dns_record_set.authorization_records](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set)                                                | resource    |
| [google_dns_managed_zone.domain](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/dns_managed_zone)                                                        | data source |

## Inputs

| Name                                                                                           | Description                                                                                               | Type     | Default | Required |
|------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|----------|---------|:--------:|
| <a name="input_dns_record_set_ttl"></a> [dns\_record\_set\_ttl](#input\_dns\_record\_set\_ttl) | The Time To Live (TTL) for DNS record sets, specified in seconds. Defaults to 300 seconds (5 minutes).    | `number` | `300`   |    no    |
| <a name="input_domain"></a> [domain](#input\_domain)                                           | The domain name to be managed, such as example.com.                                                       | `string` | n/a     |   yes    |
| <a name="input_managed_zone"></a> [managed\_zone](#input\_managed\_zone)                       | The name of the managed DNS zone in Google Cloud. Defaults to null, meaning no managed zone is specified. | `string` | `null`  |    no    |

## Outputs

| Name                                                           | Description                                                                      |
|----------------------------------------------------------------|----------------------------------------------------------------------------------|
| <a name="output_cert_map"></a> [cert\_map](#output\_cert\_map) | The name of the Google Certificate Manager certificate map for wildcard domains. |
