# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2025-01-25

### Added

- Initial release of terraform-aws-keycloak-operator module
- OLM-based operator installation (recommended for 2026+)
- Manifest-based operator installation (fallback for clusters without OLM)
- Keycloak CR deployment with external PostgreSQL database support
- AWS ALB Ingress integration with kubernetes_ingress_v1
- KeycloakRealmImport CR support for initial realm configuration
- Bundled CRDs for Keycloak Operator v26.0.7
- Complete and minimal examples
- CRD update script (scripts/update-crds.sh)
