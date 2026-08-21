# Several sites in one AWS account

Response headers policy names are unique per AWS account, so a caller that instantiates this module
more than once in one account has to give each instance its own `response_headers_policy_name` -
otherwise the second one fails to create on a duplicate name.

Leaving `response_headers_policy_name` unset keeps the historical default name.

## Usage
To run this example you need to execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```
