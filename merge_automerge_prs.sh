#!/bin/bash

set -e

# Get all submodules
SUBMODULES=($(git config --file .gitmodules --get-regexp path | awk '{ print $2 }'))

echo "Finding and merging automerge workflow PRs..."
echo "Total submodules: ${#SUBMODULES[@]}"
echo ""

successful_merges=0
no_prs_found=0
failed_merges=0

for submodule in "${SUBMODULES[@]}"; do
    # List open PRs for this repo
    prs=$(gh pr list --repo "c0x12c/$submodule" --json number,title,headRefName --limit 10 2>/dev/null)

    if [ $? -ne 0 ]; then
        continue
    fi

    # Find the automerge workflow PR
    automerge_pr=$(echo "$prs" | jq -r '.[] | select(.headRefName == "ducdt/add-dependabot-automerge") | .number' | head -1)

    if [ -z "$automerge_pr" ]; then
        ((no_prs_found++))
        continue
    fi

    pr_title=$(echo "$prs" | jq -r ".[] | select(.number == $automerge_pr) | .title")

    echo "========================================="
    echo "Repository: $submodule"
    echo "Found PR #$automerge_pr: $pr_title"
    echo "Merging..."

    # Merge the PR
    gh pr merge "$automerge_pr" --repo "c0x12c/$submodule" --squash --delete-branch --admin

    if [ $? -eq 0 ]; then
        echo "✅ Successfully merged"
        ((successful_merges++))
    else
        echo "❌ Failed to merge"
        ((failed_merges++))
    fi

    echo ""
done

echo "========================================="
echo "Summary:"
echo "✅ Successfully merged: $successful_merges"
echo "ℹ️  No PRs found: $no_prs_found"
echo "❌ Failed merges: $failed_merges"
echo "========================================="
