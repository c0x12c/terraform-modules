#!/bin/bash
# Script to update Keycloak Operator CRDs to a specific version
# Usage: ./update-crds.sh [VERSION]
# Example: ./update-crds.sh 26.0.7

set -e

VERSION="${1:-26.0.7}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CRDS_DIR="${SCRIPT_DIR}/../crds"

BASE_URL="https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/${VERSION}/kubernetes"

echo "Downloading Keycloak Operator CRDs version ${VERSION}..."

# Download CRD manifests
curl -sL "${BASE_URL}/keycloaks.k8s.keycloak.org-v1.yml" > "${CRDS_DIR}/keycloaks.k8s.keycloak.org-v1.yml"
echo "  Downloaded: keycloaks.k8s.keycloak.org-v1.yml"

curl -sL "${BASE_URL}/keycloakrealmimports.k8s.keycloak.org-v1.yml" > "${CRDS_DIR}/keycloakrealmimports.k8s.keycloak.org-v1.yml"
echo "  Downloaded: keycloakrealmimports.k8s.keycloak.org-v1.yml"

curl -sL "${BASE_URL}/kubernetes.yml" > "${CRDS_DIR}/kubernetes.yml"
echo "  Downloaded: kubernetes.yml"

echo ""
echo "Successfully updated CRDs to version ${VERSION}"
echo ""
echo "Don't forget to update the default versions in variables.tf:"
echo "  - operator_version = \"${VERSION}\""
echo "  - keycloak_image = \"quay.io/keycloak/keycloak:${VERSION}\""
