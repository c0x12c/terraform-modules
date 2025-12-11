#!/bin/bash

set -e

WORKFLOW_FILE="/Users/ducduong/git/c0x12c/spartans/terraform-modules-registry/dependabot-automerge.yml"
WORKFLOW_NAME="dependabot-automerge.yml"

# Get all submodules
SUBMODULES=($(git config --file .gitmodules --get-regexp path | awk '{ print $2 }'))

echo "Found ${#SUBMODULES[@]} submodules"
echo ""

for submodule in "${SUBMODULES[@]}"; do
    echo "========================================="
    echo "Processing: $submodule"
    echo "========================================="

    # Check if submodule directory exists, if not initialize it
    if [ ! -d "$submodule/.git" ]; then
        echo "Initializing submodule..."
        git submodule update --init "$submodule"
    fi

    cd "$submodule"

    # Get the default branch
    default_branch=$(git remote show origin | grep "HEAD branch" | cut -d' ' -f5)
    echo "Default branch: $default_branch"

    # Make sure we're on the latest
    git fetch origin
    git checkout "$default_branch"
    git pull origin "$default_branch"

    # Create feature branch
    branch_name="ducdt/add-dependabot-automerge"
    git checkout -b "$branch_name" 2>/dev/null || git checkout "$branch_name"

    # Create .github/workflows directory if it doesn't exist
    mkdir -p .github/workflows

    # Copy the workflow file
    cp "$WORKFLOW_FILE" ".github/workflows/$WORKFLOW_NAME"
    echo "✅ Added workflow file"

    # Check if there are changes
    if git diff --quiet && git diff --cached --quiet; then
        echo "ℹ️  No changes - workflow already exists"
        git checkout "$default_branch"
        git branch -D "$branch_name" 2>/dev/null || true
        cd ..
        echo ""
        continue
    fi

    # Stage changes
    git add .github/workflows/$WORKFLOW_NAME

    # Commit
    git commit -m "Add Dependabot auto-merge workflow"

    # Push
    git push -u origin "$branch_name"
    echo "✅ Pushed to branch $branch_name"

    # Extract repo name from submodule path
    repo_name=$(basename "$submodule")

    # Create PR
    gh pr create \
        --repo "c0x12c/$repo_name" \
        --title "Add Dependabot auto-merge workflow" \
        --body "$(cat <<'EOF'
## Summary

This PR adds a GitHub Actions workflow to automatically merge Dependabot pull requests after all status checks pass.

### Why
Manual merging of Dependabot PRs creates unnecessary overhead. Automated merging reduces maintenance burden while ensuring updates are applied promptly.

### What
Added `.github/workflows/dependabot-automerge.yml` workflow that:
- Triggers on all pull requests
- Filters to only Dependabot-created PRs
- Uses GitHub App authentication for proper permissions
- Auto-merges GitHub Actions updates (all semver types)
- Auto-merges Terraform patch updates only
- Waits for required status checks before merging
- Uses squash merge strategy

### Solution
The workflow uses:
- GitHub App token authentication (via `GH_APP_ID` and `GH_APP_PRIVATE_KEY`)
- `dependabot/fetch-metadata` action to identify package ecosystem and update type

Auto-merge is enabled conditionally:
- **GitHub Actions**: All version updates (major, minor, patch)
- **Terraform**: Patch updates only (minor and major require manual review)

## Types of Changes
- [x] 🚀 New feature (non-breaking change which adds functionality)

## Test Plan
After merging:
1. Wait for the next Dependabot PR
2. Verify the workflow triggers and enables auto-merge
3. Verify PR merges automatically after status checks pass
EOF
)" \
        --base "$default_branch"

    echo "✅ Created PR"

    # Go back to default branch
    git checkout "$default_branch"

    cd ..
    echo ""
done

echo "========================================="
echo "Deployment completed!"
echo "========================================="
