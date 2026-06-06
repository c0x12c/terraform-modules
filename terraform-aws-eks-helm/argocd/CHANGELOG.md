# Changelog

All notable changes to this project will be documented in this file.

## [0.4.4]() (2025-04-18)

### Fix Bugs

* Fix the in_cluster_name issue

## [0.4.3]() (2025-04-18)

### Features

* Add Route53 record

### Fix Bugs

* Fix the namespace argocd is not found
* Fix the no policy define in the role_policy
* Fix the Ingress annotation to create the ALB listener rules

## [0.4.2]() (2025-04-17)

### Features

* Change variables that defined in `camelCase` to `snake_case`
  * `var.external_cluster`
    * assumeRoles -> assume_role
    * clusterResources -> cluster_resources
    * awsAuthConfig -> aws_auth_config
    * clusterName -> cluster_name
    * roleARN -> role_arn
    * tlsClientConfig -> tls_client_config
    * caData -> ca_data
* Add variable `enabled_managed_in_cluster` to enable in_cluster management, and `in_cluster_name` to change its name when `enabled_managed_in_cluster` is enable

## [0.3.15]() (2025-04-11)

### Features

* Add predefined group rules for projects.
* Update destinations for projects and root applications
* Update condition for adding in-cluster and rename it

## [0.3.12]() (2025-04-10)

### Features

* Add annotations for adding new roles

### Fix Bugs

* Fix Github Repository Connection
* Fix projects permission
* Update OIDC arn to OIDC url for cluster connection

### Fix Bugs

* Fix issues relating to yaml format in `tolerations`
* Change `oidc_role_arn` to `oidc_url`
* Fix indent for cluster connections

## [0.3.8]() (2025-04-04)

### Features

* Convert to `yaml` file
* Update Ingress and OIDC Connection
* Add `issuer_url` for dex config

## [0.3.6]() (2025-04-04)

### Features

* Add tolerants which will schedule argocd to managed node

## [0.3.5]() (2025-04-04)

### Fix Bugs

* Remove those attributes when creating helm argocd
```hcl
  wait             = true
  timeout          = 300
```

## [0.3.3]() (2025-04-03)

### Features

* Update provider version
* Split CRDs include `Projects` and `Applications` to a single sub-module, which will handle creating Projects and Applications.

## [0.3.2]() (2025-04-01)

### Features

* Initial commit with all the code
