#!/bin/bash

# Script to process Dependabot PRs across all submodules
# Usage: ./process_dependabot_prs.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get list of submodules
submodules=$(git submodule status | awk '{print $2}')

total_submodules=$(echo "$submodules" | wc -l | tr -d ' ')
current=0
skipped=0
processed=0
failed=0

echo -e "${BLUE}Found $total_submodules submodules${NC}\n"

for submodule in $submodules; do
    current=$((current + 1))
    echo -e "${BLUE}[$current/$total_submodules] Processing: $submodule${NC}"

    # Assume the GitHub repo name is the same as the submodule directory name
    repo_name="c0x12c/$submodule"

    # Check for open Dependabot PRs
    echo "  Checking for Dependabot PRs in $repo_name..."

    # Get list of open PRs authored by dependabot
    prs=$(gh pr list --repo "$repo_name" --author "app/dependabot" --state open --json number,title 2>/dev/null || echo "[]")

    # Count PRs
    pr_count=$(echo "$prs" | jq '. | length' 2>/dev/null || echo "0")

    if [ "$pr_count" -eq 0 ]; then
        echo -e "  ${YELLOW}No open Dependabot PRs found (likely already processed)${NC}\n"
        skipped=$((skipped + 1))
        continue
    fi

    echo -e "  ${GREEN}Found $pr_count Dependabot PR(s)${NC}"

    # Process each PR
    pr_numbers=$(echo "$prs" | jq -r '.[].number')

    for pr_number in $pr_numbers; do
        pr_title=$(echo "$prs" | jq -r ".[] | select(.number == $pr_number) | .title")
        echo "    Processing PR #$pr_number: $pr_title"

        # Approve the PR
        echo "      Approving..."
        if gh pr review "$pr_number" --repo "$repo_name" --approve 2>/dev/null; then
            echo -e "      ${GREEN}✓ Approved${NC}"
        else
            echo -e "      ${YELLOW}⚠ Already approved or approval failed${NC}"
        fi

        # Merge the PR (using squash merge)
        echo "      Merging..."
        if gh pr merge "$pr_number" --repo "$repo_name" --squash --auto 2>/dev/null; then
            echo -e "      ${GREEN}✓ Merged successfully${NC}"
            processed=$((processed + 1))
        else
            echo -e "      ${RED}✗ Merge failed (may need checks to pass or already merged)${NC}"
            failed=$((failed + 1))
        fi
    done

    echo ""
done

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Summary:${NC}"
echo -e "  Total submodules: $total_submodules"
echo -e "  ${GREEN}Processed PRs: $processed${NC}"
echo -e "  ${YELLOW}Skipped (no PRs): $skipped${NC}"
echo -e "  ${RED}Failed: $failed${NC}"
echo -e "${BLUE}========================================${NC}"
