# IAM database authentication example

Aurora PostgreSQL cluster whose `app` and `migrator` database roles connect with IAM authentication
instead of a password. The module builds the `rds-db:connect` policy and exports its ARN; this
example attaches it to a role the caller owns.

```bash
terraform init
terraform plan
terraform apply
```

## What the module does and does not do

- Builds one policy covering every role in `iam_auth_db_roles`. An Aurora cluster has a single
  resource ID, so all roles share the cluster-scoped ARN.
- Exports `iam_auth_policy_arn`. It is `null` when `iam_auth_db_roles` is empty, so nothing is
  created for callers that do not use IAM auth.
- Does **not** attach the policy, and does **not** create the database roles. The IAM principal
  usually lives outside this module, and the roles are created by a migration or bootstrap step.

## Database side

The names in `iam_auth_db_roles` are Postgres roles, not IAM principals. Each must exist and hold
`rds_iam` membership before a token will be accepted:

```sql
CREATE ROLE app LOGIN;
GRANT rds_iam TO app;
```

The master user cannot be one of them. RDS refuses to grant `rds_iam` to a role that also
authenticates with a password, so a component needing both paths requires its own role.
