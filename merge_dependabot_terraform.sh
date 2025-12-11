#!/bin/bash

# List of submodules with Terraform dependency PRs to merge
SUBMODULES=(
    "terraform-aws-github-self-hosted-runners"
    "terraform-cloudflare-record-with-cache-rule"
    "terraform-aws-s3"
    "terraform-datadog-aws-integration"
)

echo "Starting Terraform dependency PR merge process..."
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

    # Find Terraform dependency PR (authored by dependabot)
    terraform_pr=$(echo "$prs" | jq -r '.[] | select(.author.login == "app/dependabot" and (.title | contains("deps-terraform"))) | .number' | head -1)

    if [ -z "$terraform_pr" ]; then
        echo "ℹ️  No Terraform dependency PR found"
    else
        echo "Found PR #$terraform_pr"
        pr_title=$(echo "$prs" | jq -r ".[] | select(.number == $terraform_pr) | .title")
        echo "Title: $pr_title"

        # Merge the PR
        echo "Merging PR #$terraform_pr..."
        gh pr merge "$terraform_pr" --repo "c0x12c/$submodule" --squash --delete-branch --admin

        if [ $? -eq 0 ]; then
            echo "✅ Successfully merged PR #$terraform_pr"
        else
            echo "❌ Failed to merge PR #$terraform_pr"
        fi
    fi
    echo ""
done

echo "========================================="
echo "Process completed!"
echo "========================================="
