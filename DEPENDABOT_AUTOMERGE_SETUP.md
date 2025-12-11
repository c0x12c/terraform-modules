# Dependabot Auto-Merge Setup

This document describes the setup of automated Dependabot PR merging across all terraform module repositories.

## What Was Done

### 1. Merged Existing Dependabot PRs (Completed)

**GitHub Actions PRs (19 repositories):**
- Merged PRs upgrading `actions/checkout` from v5 to v6
- Used `--admin` flag to bypass branch protection

**Terraform Dependency PRs (4 repositories):**
- `terraform-aws-github-self-hosted-runners`: hashicorp/aws 6.0.0 → 6.23.0
- `terraform-cloudflare-record-with-cache-rule`: cloudflare/cloudflare ~5.7.1 → ~5.13.0
- `terraform-aws-s3`: hashicorp/aws 6.9.0 → 6.23.0
- `terraform-datadog-aws-integration`: DataDog/datadog ~3.71.0 → ~3.81.0

### 2. Created Dependabot Auto-Merge Workflow

**File:** `dependabot-automerge.yml`

**Key Features:**
- Uses GitHub App authentication for proper permissions
- Auto-merges GitHub Actions updates (all semver types: major, minor, patch)
- Auto-merges Terraform updates (patch only, excludes minor and major)
- Waits for required status checks before merging
- Uses squash merge strategy

**Authentication:**
```yaml
- name: Create GitHub App Token
  uses: actions/create-github-app-token@v2
  id: github-app-token
  with:
    app-id: ${{ vars.GH_APP_ID }}
    private-key: ${{ secrets.GH_APP_PRIVATE_KEY }}
```

**Requirements:**
- Repository must have `GH_APP_ID` variable configured
- Repository must have `GH_APP_PRIVATE_KEY` secret configured
- Auto-merge must be enabled in repository settings

### 3. Test Deployment (Completed)

Deployed workflow to 3 test repositories:
- `terraform-aws-helm-neo4j` (PR #4)
- `terraform-datadog-gcp-monitor` (PR #3)
- `terraform-gcp-artifact-registry` (PR #3)

## Files Created

1. **dependabot-automerge.yml** - The workflow file to be deployed
2. **merge_dependabot_github_actions.sh** - Script to merge GitHub Actions PRs
3. **merge_dependabot_terraform.sh** - Script to merge Terraform dependency PRs
4. **deploy_automerge_test.sh** - Test deployment to 3 repositories
5. **deploy_automerge_workflow.sh** - Full deployment script for all submodules
6. **update_test_prs.sh** - Script to update test PRs

## Next Steps

### Step 1: Review and Merge Test PRs

Review the following test PRs:
- https://github.com/c0x12c/terraform-aws-helm-neo4j/pull/4
- https://github.com/c0x12c/terraform-datadog-gcp-monitor/pull/3
- https://github.com/c0x12c/terraform-gcp-artifact-registry/pull/3

### Step 2: Verify Workflow Operation

After merging one test PR:
1. Wait for the next Dependabot PR in that repository
2. Check workflow execution in Actions tab
3. Verify auto-merge is enabled on the PR
4. Verify PR merges automatically after status checks pass

### Step 3: Deploy to All Submodules

Once verified, deploy to all submodules:
```bash
cd /Users/ducduong/git/c0x12c/spartans/terraform-modules-registry
./deploy_automerge_workflow.sh
```

This will:
- Initialize all submodules
- Create feature branches (`ducdt/add-dependabot-automerge`)
- Add the workflow file
- Create PRs in each repository

### Step 4: Verify GitHub App Credentials

Ensure all repositories have access to:
- `vars.GH_APP_ID` (organization or repository variable)
- `secrets.GH_APP_PRIVATE_KEY` (organization or repository secret)

If these are organization-level secrets/variables, they should already be accessible. If repository-level, they need to be configured for each repo.

### Step 5: Enable Auto-Merge in Repository Settings

For each repository, verify that auto-merge is enabled:
1. Go to repository Settings
2. Navigate to General → Pull Requests
3. Ensure "Allow auto-merge" is checked

## Troubleshooting

### Auto-merge not working

**Symptom:** Workflow runs but doesn't enable auto-merge

**Causes:**
1. Auto-merge not enabled in repository settings
2. GitHub App credentials missing or incorrect
3. Branch protection rules preventing auto-merge

**Solutions:**
1. Enable auto-merge in repository settings
2. Verify `GH_APP_ID` and `GH_APP_PRIVATE_KEY` are configured
3. Check branch protection rules allow auto-merge

### Workflow doesn't trigger

**Symptom:** Workflow doesn't run on Dependabot PRs

**Causes:**
1. Workflow file not in master/main branch
2. Workflow syntax error

**Solutions:**
1. Verify workflow file exists in `.github/workflows/`
2. Check workflow syntax in Actions tab

## Workflow Logic

```yaml
GitHub Actions Updates:
  - Major: ✅ Auto-merge
  - Minor: ✅ Auto-merge
  - Patch: ✅ Auto-merge

Terraform Updates:
  - Major: ❌ Manual review required
  - Minor: ❌ Manual review required
  - Patch: ✅ Auto-merge
```

## Benefits

1. **Reduced Manual Work:** No more manual merging of routine dependency updates
2. **Faster Updates:** Dependencies are applied as soon as checks pass
3. **Consistent Process:** All repositories follow the same merge strategy
4. **Security:** Updates are applied promptly, reducing security vulnerabilities
5. **Safe Defaults:** Major and minor Terraform updates require manual review for breaking changes

## Documentation Reference

Based on GitHub's official documentation:
https://docs.github.com/en/code-security/dependabot/working-with-dependabot/automating-dependabot-with-github-actions
