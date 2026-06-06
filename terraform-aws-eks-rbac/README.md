# EKS RBAC

Reference: [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

## Terminologies

- General

    - Cluster: is a set of nodes, including physical (EC2) or virtual (Fargate) machines that run containerized
      applications. The cluster is the fundamental unit of Kubernetes deployment, and it orchestrates the deployment,
      scaling, and management of containerized applications.

    - Namespace: is like a virtual cluster inside a physical cluster. It provides a way to divide cluster resources
      between multiple users or projects. Each namespace has its own set of resources, and objects within one namespace
      are isolated from those in other namespaces.


- RBAC: is a security mechanism that controls access to resources within a cluster. It allows you to define who (users
  or groups) can do what (verbs) on which resources (nouns).


- Roles and RoleBindings:

    - Role: set of permissions defined for a specific namespace. It specifies what actions (verbs) are allowed on which
      resources (nouns) within that namespace. For example, a role might grant read access to pods in a namespace.

    - RoleBinding: A role binding binds a role to a user, a group, or a service account within a specific namespace. It
      establishes the connection between the role and the entity (user, group, or service account) that should have the
      defined permissions.

- ClusterRoles and ClusterRoleBindings:

    - ClusterRole: Similar to a role, but it works across all namespaces in a cluster. It defines permissions for
      cluster-level resources, like nodes and persistent volumes.

    - ClusterRoleBinding: Binds a cluster role to a user, group, or service account across the entire cluster. It allows
      users or service accounts to have specific roles across all namespaces

## How we apply them

We are making use of Kubernetes RBAC for adding permission entries for AWS IAM roles through EKS built in
feature [Enabling IAM principal access to your cluster - Amazon EKS ](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html)

From within our Infrastructure repository, we’ve defined this piece of code in the K8s-RBAC Terraform module for
defining ClusterRole and Namespace Roles

```
cluster_roles = [
{
  name      = "admin"
  privilege = "admin"
  trusted_role_arn = [
    local.administrator_role_arn
  ]
},
{
  name      = "developer"
  privilege = "developer"
  trusted_role_arn = [
    local.developer_role_arn
  ]
}
]

namespace_roles = [
{
  namespace = "service-bot"
  privilege = "readonly"
  trusted_role_arn = [
    local.service_bot_readonly_role_arn
  ]
},
{
  namespace = "service-crypto"
  privilege = "developer"
  trusted_role_arn = [
    local.service_crypto_developer_role_arn
  ]
}
]
```

Under the hood, this Terraform code creates the resources below

- An IAM role that trust the role arns in trusted_role_arn to assume it with sts:AssumeRole

- IAM roles for cluster: eks-admin-clusterrole and eks-developer-clusterrole

- IAM roles for namespace: eks-service-bot-readonly-namespace-role and eks-service-crypto-developer-namespace-role

- ClusterRole and ClusterRoleBindings for cluster_roles array

- Role and RoleBinding for namespace_roles array

These ClusterRoleBindings and RoleBindings then will be linked to AWS IAM through aws-auth configmap inside kube-system
namespace as the documentation above described

```
- rolearn: arn:aws:iam::<account-id>:role/eks-admin-clusterrole
  username: admin
  groups:
  - custom:admin-group                      # clusterrolebinding
- rolearn: arn:aws:iam::<account-id>:role/eks-developer-clusterrole
  username: developer
  groups:
  - custom:developer-group                  # clusterrolebinding
- rolearn:
arn:aws:iam::<account-id>:role/eks-service-bot-readonly-namespace-role
  username: service-bot-readonly
  groups:
  - custom:service-bot-readonly-group       # rolebinding
- rolearn:
arn:aws:iam::<account-id>:role/eks-service-crypto-developer-namespace-role
  username: service-crypto-developer
  groups:
  - custom:service-crypto-developer-group   # rolebinding
```

## How does the trusted role work?

As you can see from the previous sections, we specify which IAM roles are trusted by the newly created IAM roles through
trusted_role_arns variable

If the user has permission to use this SSO role through logging in by SSO, he/she will have the permission to assume the
eks-admin-clusterrole and perform actions inside the Kubernetes Cluster

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                         | Version   |
|------------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)    | >= 1.9.8  |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                      | >= 5.75.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.33   |

## Providers

| Name                                                                   | Version   |
|------------------------------------------------------------------------|-----------|
| <a name="provider_aws"></a> [aws](#provider\_aws)                      | >= 5.75.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.33   |

## Modules

No modules.

## Resources

| Name                                                                                                                                              | Type        |
|---------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_iam_role.this_cluster_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                            | resource    |
| [aws_iam_role.this_namespace_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                          | resource    |
| [kubernetes_cluster_role.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role)                   | resource    |
| [kubernetes_cluster_role_binding.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding)   | resource    |
| [kubernetes_config_map_v1_data.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1_data)   | resource    |
| [kubernetes_role.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role)                                   | resource    |
| [kubernetes_role_binding.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding)                   | resource    |
| [aws_iam_policy_document.this_cluster_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)   | data source |
| [aws_iam_policy_document.this_namespace_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name                                                                                                       | Description                                                                                                                                                 | Type                                                                                                                                                       | Default | Required |
|------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_aws_auth_accounts"></a> [aws\_auth\_accounts](#input\_aws\_auth\_accounts)                  | Additional AWS accounts to be added to the aws-auth configmap. These accounts will link between Kubernetes Users and AWS IAM accounts                       | `list`                                                                                                                                                     | `[]`    |    no    |
| <a name="input_aws_auth_users"></a> [aws\_auth\_users](#input\_aws\_auth\_users)                           | Additional AWS IAM users to be added to the aws-auth configmap. These users will link between Kubernetes Users and AWS IAM users                            | `list`                                                                                                                                                     | `[]`    |    no    |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)                                   | EKS Cluster name                                                                                                                                            | `string`                                                                                                                                                   | n/a     |   yes    |
| <a name="input_cluster_roles"></a> [cluster\_roles](#input\_cluster\_roles)                                | Additional IAM roles to be created and added to the aws-auth configmap. These roles will link between Kubernetes Cluster Roles and AWS IAM roles            | <pre>list(object({<br/>    name             = string<br/>    privilege        = string<br/>    trusted_role_arn = list(string)<br/>  }))</pre>             | `[]`    |    no    |
| <a name="input_existing_aws_auth_data"></a> [existing\_aws\_auth\_data](#input\_existing\_aws\_auth\_data) | Existing aws-auth data                                                                                                                                      | `string`                                                                                                                                                   | `""`    |    no    |
| <a name="input_iam_path"></a> [iam\_path](#input\_iam\_path)                                               | If provided, all IAM roles will be created on this path.                                                                                                    | `string`                                                                                                                                                   | `"/"`   |    no    |
| <a name="input_namespace_roles"></a> [namespace\_roles](#input\_namespace\_roles)                          | Additional IAM roles to be created and added to the aws-auth configmap. These roles will link between Kubernetes Namespace Roles and AWS IAM roles          | <pre>list(object({<br/>    namespace        = string<br/>    privilege        = string<br/>    trusted_role_arn = list(string)<br/>  }))</pre>             | `[]`    |    no    |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary)           | If provided, all IAM roles will be created with this permissions boundary attached.                                                                         | `string`                                                                                                                                                   | `null`  |    no    |
| <a name="input_profile_roles"></a> [profile\_roles](#input\_profile\_roles)                                | Additional IAM roles existing from AWS will be added to the aws-auth configmap. These roles will link between Kubernetes Group permission and AWS IAM roles | <pre>list(object({<br/>    name         = string<br/>    privilege    = string<br/>    profile_type = string<br/>    role_arn     = string<br/>  }))</pre> | `[]`    |    no    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
