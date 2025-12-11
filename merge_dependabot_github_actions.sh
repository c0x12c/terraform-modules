#!/bin/bash

# List of submodules with GitHub Actions PRs to merge
SUBMODULES=(
    "terraform-aws-helm-neo4j"
    "terraform-datadog-gcp-monitor"
    "terraform-gcp-artifact-registry"
    "terraform-github-action-secrets"
    "terraform-aws-github-self-hosted-runners"
    "terraform-aws-jenkins-oidc"
    "terraform-aws-cloudwatch-alarm"
    "terraform-gcp-storage-bucket"
    "terraform-gcp-gke-ingress"
    "terraform-aws-vpc"
    "terraform-datadog-gcp-integration"
    "terraform-cloudflare-record-with-cache-rule"
    "terraform-aws-oidc"
    "terraform-aws-s3"
    "terraform-datadog-aws-integration"
    "terraform-aws-helm-nginx-ingress-controller"
    "terraform-gcp-wildcard-sslcert"
    "terraform-aws-ecs-cluster"
    "terraform-datadog-aws-monitor"
    "terraform-gcp-gke-autopilot"
    "terraform-aws-password-generator"
)

echo "Starting GitHub Actions PR merge process..."
echo "Total submodules to process: ${#SUBMODULES[@]}"
echo ""

for submodule in "${SUBMODULES[@]}"; do
    echo "========================================="
    echo "Processing: $submodule"
    echo "========================================="

    # List all open PRs using full repo path
    echo "Checking for open PRs in c0x12c/$submodule..."
    prs=$(gh pr list --repo "c0x12c/$submodule" --json number,title,author --limit 10 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo "⚠️  Failed to access repository c0x12c/$submodule"
        echo ""
        continue
    fi

    # Find GitHub Actions PR (authored by dependabot)
    gh_actions_pr=$(echo "$prs" | jq -r '.[] | select(.author.login == "app/dependabot" and (.title | contains("deps-gh-actions"))) | .number' | head -1)

    if [ -z "$gh_actions_pr" ]; then
        echo "ℹ️  No GitHub Actions PR found"
    else
        echo "Found PR #$gh_actions_pr"
        pr_title=$(echo "$prs" | jq -r ".[] | select(.number == $gh_actions_pr) | .title")
        echo "Title: $pr_title"

        # Merge the PR
        echo "Merging PR #$gh_actions_pr..."
        gh pr merge "$gh_actions_pr" --repo "c0x12c/$submodule" --squash --delete-branch --admin

        if [ $? -eq 0 ]; then
            echo "✅ Successfully merged PR #$gh_actions_pr"
        else
            echo "❌ Failed to merge PR #$gh_actions_pr"
        fi
    fi
    echo ""
done

echo "========================================="
echo "Process completed!"
echo "========================================="
