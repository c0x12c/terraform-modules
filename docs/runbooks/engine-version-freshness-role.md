# Read-only AWS role for the engine-version freshness cron

The weekly `engine-version-freshness` workflow asks AWS whether the engine
versions our modules default to are still orderable. It makes describe/list
calls only and creates nothing, so it runs with its own **read-only** role,
assumed via GitHub OIDC - no long-lived access keys in this repo.

## Why this check exists

`terraform-aws-rds` defaulted to Postgres `16.4`. AWS retired that minor
version, and from that day every greenfield `apply` on the module defaults
failed with `InvalidParameterCombination: Cannot find version 16.4 for
postgres`. Nothing went red: the module had not changed, so there was no PR to
attach a test to, and `fmt` / `validate` / `tflint` / `plan` all still passed.
Existing instances were unaffected, so the break stayed invisible until someone
stood up a new database.

A scheduled read-only assertion is the only shape of test that catches this,
because the thing that changes is on AWS's side, not ours.

## One-time provisioning

1. **Create the IAM role** in the account whose region availability you want to
   assert against (version availability is regional; the workflow defaults to
   `us-west-2`).

   Trust policy - GitHub OIDC, scoped to this repository:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [{
       "Effect": "Allow",
       "Principal": {
         "Federated": "arn:aws:iam::<account-id>:oidc-provider/token.actions.githubusercontent.com"
       },
       "Action": "sts:AssumeRoleWithWebIdentity",
       "Condition": {
         "StringEquals": {
           "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
         },
         "StringLike": {
           "token.actions.githubusercontent.com:sub": "repo:c0x12c/terraform-modules:*"
         }
       }
     }]
   }
   ```

   Permissions policy - exactly the calls the checker makes, nothing else:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [{
       "Effect": "Allow",
       "Action": [
         "rds:DescribeDBEngineVersions",
         "docdb:DescribeDBEngineVersions",
         "elasticache:DescribeCacheEngineVersions",
         "es:ListVersions",
         "eks:DescribeClusterVersions"
       ],
       "Resource": "*"
     }]
   }
   ```

   These APIs describe service-level metadata and do not support
   resource-level scoping, hence `"Resource": "*"`. They return no customer
   data - only the list of versions AWS offers.

2. **Add the GitHub repository secret:**
   - `VERSION_FRESHNESS_ROLE_ARN` = the role ARN from step 1

## Until the secret exists

The workflow **skips** the AWS check when `VERSION_FRESHNESS_ROLE_ARN` is
absent, logging a warning on the run rather than failing. That is deliberate: a
cron that opens the same failure issue every Monday for a missing secret trains
people to ignore the label, which is the one failure mode this check cannot
afford.

The consequence is that until the role is provisioned the check is **not
protecting anything** - a green (skipped) run does not mean the versions are
fine. Check the run's warning annotation if you are unsure which state you are
in.

The PR `self-test` job runs regardless and needs no AWS access.

## Verify

Once the secret exists and the change is merged, trigger it manually
(*Actions -> Engine version freshness -> Run workflow*) and confirm green. A
red run opens (or comments on) a single bot-owned issue labelled
`engine-version-freshness`, and a later green run closes it.

## Adding a module to the check

Append an entry to `CHECKS` in `scripts/check_engine_version_freshness.py`
with the module directory, the variable holding the version, and the read-only
describe command. Add the matching IAM action to the policy above.

Only **AWS-managed** versions belong in this check - versions AWS retires on
its own schedule. Helm chart and container image versions are deliberately
excluded: those are pinned deliberately, an old pin keeps working, and
Dependabot already covers them. A gate that fires on "not the newest" rather
than "no longer exists" is noise, and a noisy gate gets muted.
