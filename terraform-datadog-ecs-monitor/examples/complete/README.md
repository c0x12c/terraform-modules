# Complete Example

This example demonstrates the full usage of the terraform-datadog-ecs-monitor module for both Fargate and EC2 launch types.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Features Demonstrated

### Fargate Example
- Service and task monitors for a specific ECS service
- APM monitors with custom latency and error thresholds
- Custom threshold overrides

### EC2 Example
- Monitoring all services in a cluster (wildcard)
- Cluster-level monitors (only available for EC2 launch type)
- Monitor configuration overrides
