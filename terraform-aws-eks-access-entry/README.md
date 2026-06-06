# AWS EKS Access Entry Terraform module

Terraform module which creates Amazon EKS (Kubernetes) resources

This module will create the components below

- Add support for access entries to manage EKS access policies, along with private/public endpoint restrictions.

## Usage

### Create EKS Access Entry

```hcl
module "eks-access-entry" {
  source = "github.com/spartan-stratos/terraform-modules//aws/eks-access-entry?ref=v0.3.0"

  aws_account_id = "<account-id>"
  cluster_name   = "example-cluster"
  access_entries = {
    /*
      Role for cluster administrators with full access to the EKS cluster
     */
    admin-role = {
      principal_name = "admin-role"
      policy_arn     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      trusted_role_arn = [
        "arn:aws:iam::<account-id>:role/aws-reserved/sso.amazonaws.com/us-west-2/SpartanAdministratorAccess",
        "arn:aws:iam::<account-id>:role/aws-reserved/sso.amazonaws.com/us-west-2/SpartanPowerUserAccess"
      ]
    }
    /*
      Role for cluster developers with view-only access to the EKS cluster
     */
    developer-role = {
      principal_name = "developer-role"
      policy_arn     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterViewPolicy"
      trusted_role_arn = [
        "arn:aws:iam::<account-id>:role/aws-reserved/sso.amazonaws.com/us-west-2/SpartanAdministratorAccess"
      ]
    }
    /* 
      Role for managing access to a specific namespace in the EKS cluster
     */
    service-platform-role = {
      principal_name = "service-platform-role"
      policy_arn     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
      trusted_role_arn = [
        "arn:aws:iam::<account-id>:role/aws-reserved/sso.amazonaws.com/us-west-2/SpartanAdministratorAccess"
      ]
      access_type = "namespace"
      namespaces = ["service-platform"]
    }
    /*
      Pre-existing role used for CI/CD pipelines within GitHub Actions
     */
    role-terraform-ops = {
      principal_name = "github-actions/role-terraform-ops"
      policy_arn     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
    }
  }
}

```

## Examples

- [Example](./examples/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                         | Version   |
|------------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)    | >= 1.9.8  |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                      | >= 5.75   |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.33.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls)                      | >= 4.0    |

## Providers

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                | Type        |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_eks_access_entry.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry)                           | resource    |
| [aws_eks_access_policy_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource    |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                           | resource    |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                  | data source |

## Inputs

| Name                                                                                             | Description                                                                         | Type                                                                                                                                                                                                                                                                                                                                                                            | Default | Required |
|--------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries)                   | List of access entries for EKS access entries and policies                          | <pre>map(object({<br/>    principal_name    = string<br/>    kubernetes_groups = optional(list(string))<br/>    type              = optional(string)<br/>    policy_arn        = optional(string)<br/>    namespaces        = optional(list(string))<br/>    trusted_role_arn  = optional(list(string))<br/>    access_type       = optional(string, "cluster")<br/>  }))</pre> | `{}`    |    no    |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id)                 | The AWS account ID to which the IAM SSO group will be assigned.                     | `string`                                                                                                                                                                                                                                                                                                                                                                        | n/a     |   yes    |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)                         | The name of the EKS cluster.                                                        | `string`                                                                                                                                                                                                                                                                                                                                                                        | n/a     |   yes    |
| <a name="input_custom_namespaces"></a> [custom\_namespaces](#input\_custom\_namespaces)          | Custom namespaces to be created during initialization                               | `list(string)`                                                                                                                                                                                                                                                                                                                                                                  | `[]`    |    no    |
| <a name="input_iam_path"></a> [iam\_path](#input\_iam\_path)                                     | If provided, all IAM roles will be created on this path.                            | `string`                                                                                                                                                                                                                                                                                                                                                                        | `"/"`   |    no    |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | If provided, all IAM roles will be created with this permissions boundary attached. | `string`                                                                                                                                                                                                                                                                                                                                                                        | `null`  |    no    |

## Outputs

| Name                                                                                     | Description                                                                                           |
|------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|
| <a name="output_access_entry_arn"></a> [access\_entry\_arn](#output\_access\_entry\_arn) | Map of principal\_arn to the associated access entry ARN for each access entry in the AWS EKS cluster |

<!-- END_TF_DOCS -->