#!/bin/bash

set -e

WORKFLOW_FILE="/Users/ducduong/git/c0x12c/spartans/terraform-modules-registry/dependabot-automerge.yml"
WORKFLOW_NAME="dependabot-automerge.yml"

TEST_SUBMODULES=(
    "terraform-aws-helm-neo4j"
    "terraform-datadog-gcp-monitor"
    "terraform-gcp-artifact-registry"
)

echo "Updating test PRs with GitHub App token authentication"
echo ""

for submodule in "${TEST_SUBMODULES[@]}"; do
    echo "========================================="
    echo "Processing: $submodule"
    echo "========================================="

    cd "$submodule"

    # Checkout the feature branch
    branch_name="ducdt/add-dependabot-automerge"
    git checkout "$branch_name"

    # Copy the updated workflow file
    cp "$WORKFLOW_FILE" ".github/workflows/$WORKFLOW_NAME"
    echo "✅ Updated workflow file"

    # Check if there are changes
    if git diff --quiet; then
        echo "ℹ️  No changes needed"
        git checkout master
        cd ..
        echo ""
        continue
    fi

    # Stage and commit changes
    git add .github/workflows/$WORKFLOW_NAME
    git commit -m "Use GitHub App token for auto-merge authentication"

    # Push
    git push origin "$branch_name"
    echo "✅ Pushed updated workflow"

    # Go back to master
    git checkout master

    cd ..
    echo ""
done

echo "========================================="
echo "Update completed!"
echo "========================================="
