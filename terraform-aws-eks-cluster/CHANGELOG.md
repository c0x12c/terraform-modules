# Changelog

All notable changes to this project will be documented in this file.

## [1.0.2]() (2025-10-27)

### Bug fixes

*  Set Default Kubernetes Version for EKS Managed Node Group Instead of Null

## [1.0.1]() (2025-07-16)

### Bug fixes

* Fix the `node_selector` and `tolerations` variables for EFS CSI add-on default to empty values

## [1.0.0]() (2025-07-11)

### Features

* Change modules source to c0x12c terraform registry

## [0.3.9]() (2025-04-08)

### Features

* Add the CoreDNS and EFS_CSI replica_count, node_selector and tolerations
* Add the policy AmazonEFSCSIDriverPolicy to NodeGroup instance role
* Add the custom instance role for NodeGroup

## [0.3.0]() (2025-03-30)

### Features

* Add the managed node labels

## [0.1.81]() (2025-03-12)

### Features

* Add support for the EFS CSI driver in EKS Managed Node Groups

## [0.1.78]() (2025-03-10)

### Bug fixes
* Managed nodes: only add iam role policy when there is at least 1 statemenet
* Managed nodes: don't ignore desired_size

## [0.1.76]() (2025-03-07)
* Add `service_accounts` variables to handle custom service account which will be a map with structure
```
{
    namespace = ["service-account1", "service-account2] 
}
```

## [0.1.75]() (2025-03-07)

### Bug fixes
* Remove AmazonEKS_CNI_IPv6_Policy policy and policy attachments

## [0.1.74]() (2025-03-06)

### Bug fixes
* Correct taints type

## [0.1.69]() (2025-02-21)

### Features

* Add Managed Node Group module
* Update default cluster_version to `1.32`
* Add tag for Managed Node Group to cluster and security group
* Add Managed Node Group role ARNs to `aws-auth` configmap

## [0.1.66]() (2025-02-12)

### Features

* Enable or disable access mode dynamically in the access_config of the EKS cluster resource

## [0.1.65]() (2025-02-05)

### Features

* Add EKS access entries and API/config map authentication options
* Remove deprecated access_config block from EKS cluster

## [0.1.59]() (2025-01-21)

### Features

* Add variables `enabled_endpoint_private_access`, `enabled_endpoint_public_access`, `addons_coredns_version` to
  restrict private access or public access for the Kubernetes API server endpoint

## [0.1.55]() (2025-01-14)

### Features

* Add variables `addons_vpc_cni_version`, `addons_kube_proxy_version`, `addons_coredns_version` to specify the version
  of addons.

## [0.1.35]() (2025-01-03)

### Features

* Update provider urls (remove `registry.terraform.io`) in order for OpenTofu to map to their registry.

## [0.1.28]() (2024-12-27)

### Features

* Add `var.efs_filesystem_name` to overwrite the default efs filesystem name

## [0.1.19]() (2024-12-23)

### Features

* Add output datadog_agent_cluster_role_name to root module and remove default value of datadog_agent_cluster_role_name
  in submodule
* Change assume policy of `eks-node-cluster` from `eks.amazonaws.com` to `ec2.amazonaws.com`

## [0.1.4]() (2024-12-05)

### Features

* Update terraform version constraint from `~> 1.9.8` to `>= 1.9.8`

## [0.1.0]() (2024-11-06)

### Features

* Initial commit with all the code

