# Complete example

Full two-Region setup: a us-west-2 instance owning the Slack channel, and a
us-east-1 instance for global events whose topic is subscribed by the first via
`additional_sns_topic_arns`. Both set `exclude_backup_events` so each event
alerts once.

Runnable example for the module:

```bash
terraform init
terraform plan
```
