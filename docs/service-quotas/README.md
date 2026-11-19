# AWS service quota catalog

Look up the `service_code` and `quota_code` that the
[`terraform-aws-service-quota`](../../terraform-aws-service-quota) module needs.

## About this catalog

<!-- BEGIN catalog-metadata -->
- Generated: 2026-11-19 (UTC) by `scripts/generate_service_quota_catalog.py`
- Region: `us-west-2`
- Services: 286; quotas: 13622
- Source APIs: ListServices, ListAWSDefaultServiceQuotas
<!-- END catalog-metadata -->

- **Purpose:** a snapshot for finding a `service_code` and `quota_code` quickly, including
  on GitHub without AWS access. It is not the source of truth.
- **Limits:** AWS adds quotas and changes default values over time. `default_value` is the
  AWS default, not what any account currently has applied, and defaults can differ outside
  `us-west-2`.
- **Before raising a quota**, always read the applied value live and set `value` from that,
  never from this catalog:

  ```bash
  aws service-quotas get-service-quota --service-code ec2 --quota-code L-1216C47A \
    --query 'Quota.Value'
  ```

- **Quota missing here?** Search live before concluding it does not exist, with the
  generator in stdout mode (below) or, when the service code is known:

  ```bash
  aws service-quotas list-aws-default-service-quotas --service-code ec2 \
    --query "Quotas[?contains(QuotaName, 'Standard')].[QuotaCode,QuotaName,Value]" --output table
  ```

- **Refresh:** run the generator with any read-only profile (default quotas do not depend on
  the account) and open a `docs:` PR. It rewrites every CSV, deletes the CSV of a service AWS
  no longer lists, and rewrites the metadata and service index blocks of this README.

  ```bash
  pip install -r scripts/requirements.txt
  python3 scripts/generate_service_quota_catalog.py --output-dir docs/service-quotas/us-west-2
  ```

## Layout

One CSV per service in [`us-west-2/`](us-west-2), named `<service_code>.csv` and sorted by
`quota_name`. One file per service keeps each CSV small enough for GitHub to render as a
table and to index for code search.

| Column | Meaning |
|---|---|
| `service_code` | Value for the module's `service_code` |
| `service_name` | AWS service name |
| `quota_code` | Value for the module's `quota_code` (`L-` plus eight hex characters) |
| `quota_name` | AWS quota name |
| `description` | AWS description of the quota |
| `default_value` | AWS default in this region, not the applied value of any account |
| `unit` | Unit of the value (`None` for a plain count) |
| `adjustable` | `true` when an increase can be requested; the module only helps for these |
| `global_quota` | `true` when the quota is account-wide; regional listings rarely include these (see below) |

## Global quotas

Account-wide quotas, such as IAM, are listed only in `us-east-1`, so this `us-west-2` catalog
does not contain them. Find them live and manage them from a `us-east-1` provider:

```bash
aws service-quotas list-aws-default-service-quotas --region us-east-1 --service-code iam \
  --query 'Quotas[].[QuotaCode,QuotaName,Value]' --output table
```

## How to search

- **On GitHub:** open the service's CSV from the index below and type in the table's
  search box, or use code search: `repo:c0x12c/terraform-modules path:docs/service-quotas "Fargate"`.
- **Locally:** `grep -ri "on-demand standard" docs/service-quotas/us-west-2/`
- **Live, always current:** the same generator writes one CSV with every service to stdout,
  so nothing goes stale:

  ```bash
  python3 scripts/generate_service_quota_catalog.py --output - | grep -i "fargate"
  ```

## Commonly raised quotas

Codes checked against this catalog (IAM against the live `us-east-1` listing). "Approval" records only observed evidence; AWS publishes
no auto-approval thresholds and decides each request on account history and usage.

| What | service_code | quota_code | Global | Approval |
|---|---|---|---|---|
| EC2 On-Demand Standard (A, C, D, H, I, M, R, T, Z) vCPUs | `ec2` | `L-1216C47A` | no | Observed going through a support case and closing in about 1.5 to 4.5 hours (2026) |
| EC2 Standard Spot vCPUs | `ec2` | `L-34B43A08` | no | No evidence recorded |
| EC2 On-Demand G and VT vCPUs (GPU) | `ec2` | `L-DB2E81BA` | no | No evidence recorded |
| EC2-VPC Elastic IPs | `ec2` | `L-0263D0A3` | no | No evidence recorded |
| Fargate On-Demand vCPUs | `fargate` | `L-3032A538` | no | Observed going through a support case and closing in about 1.5 to 4.5 hours (2026) |
| Fargate Spot vCPUs | `fargate` | `L-36FBB829` | no | No evidence recorded |
| VPCs per Region | `vpc` | `L-F678F1CE` | no | No evidence recorded |
| Inbound or outbound rules per security group | `vpc` | `L-0EA8095F` | no | No evidence recorded |
| VPC security groups per Region | `vpc` | `L-E79EC296` | no | No evidence recorded |
| NAT gateways per Availability Zone | `vpc` | `L-FE5A380F` | no | No evidence recorded |
| Network interfaces per Region | `vpc` | `L-DF5E4CA3` | no | No evidence recorded |
| EKS clusters | `eks` | `L-1194D53C` | no | No evidence recorded |
| EKS managed node groups per cluster | `eks` | `L-6D54EA21` | no | No evidence recorded |
| RDS DB instances | `rds` | `L-7B6409FD` | no | No evidence recorded |
| Lambda concurrent executions | `lambda` | `L-B99A9384` | no | No evidence recorded |
| Application Load Balancers per Region | `elasticloadbalancing` | `L-53DA6B97` | no | No evidence recorded |
| IAM roles per account (listed in us-east-1 only) | `iam` | `L-FE177D64` | yes | No evidence recorded |

## Service index

<!-- BEGIN catalog-index -->
| service_code | Service | Quotas |
|---|---|---:|
| [`AWSCloudMap`](us-west-2/AWSCloudMap.csv) | AWS Cloud Map | 7 |
| [`access-analyzer`](us-west-2/access-analyzer.csv) | Access Analyzer | 9 |
| [`account-access`](us-west-2/account-access.csv) | Account access manager | 1 |
| [`acm`](us-west-2/acm.csv) | AWS Certificate Manager (ACM) | 42 |
| [`acm-pca`](us-west-2/acm-pca.csv) | AWS Private Certificate Authority | 27 |
| [`aco-automation`](us-west-2/aco-automation.csv) | AWS Compute Optimizer Automation | 24 |
| [`agent-registry`](us-west-2/agent-registry.csv) | AWS Agent Registry | 20 |
| [`aidevops`](us-west-2/aidevops.csv) | AWS DevOps Agent | 8 |
| [`aiops`](us-west-2/aiops.csv) | Amazon AI Operations | 3 |
| [`airflow`](us-west-2/airflow.csv) | Amazon Managed Workflows for Apache Airflow | 4 |
| [`airflow-serverless`](us-west-2/airflow-serverless.csv) | Amazon MWAA Serverless (airflow-serverless) | 7 |
| [`amplify`](us-west-2/amplify.csv) | AWS Amplify | 12 |
| [`amplifyuibuilder`](us-west-2/amplifyuibuilder.csv) | Amplify UI Builder | 8 |
| [`aoss`](us-west-2/aoss.csv) | Amazon OpenSearch Serverless | 21 |
| [`apigateway`](us-west-2/apigateway.csv) | Amazon API Gateway | 51 |
| [`app-integrations`](us-west-2/app-integrations.csv) | Amazon Connect Application Integrations | 47 |
| [`appconfig`](us-west-2/appconfig.csv) | AWS AppConfig | 8 |
| [`appflow`](us-west-2/appflow.csv) | Amazon AppFlow | 30 |
| [`application-autoscaling`](us-west-2/application-autoscaling.csv) | Application Auto Scaling | 16 |
| [`application-signals`](us-west-2/application-signals.csv) | Amazon CloudWatch Application Signals | 25 |
| [`appmesh`](us-west-2/appmesh.csv) | AWS App Mesh | 11 |
| [`apprunner`](us-west-2/apprunner.csv) | AWS App Runner | 6 |
| [`appstream2`](us-west-2/appstream2.csv) | Amazon WorkSpaces Applications | 565 |
| [`appstudio`](us-west-2/appstudio.csv) | AWS App Studio | 2 |
| [`appsync`](us-west-2/appsync.csv) | AWS AppSync | 35 |
| [`aps`](us-west-2/aps.csv) | Amazon Managed Prometheus | 37 |
| [`assurance`](us-west-2/assurance.csv) | AWS Assurance | 93 |
| [`athena`](us-west-2/athena.csv) | Amazon Athena | 30 |
| [`auditmanager`](us-west-2/auditmanager.csv) | AWS Audit Manager | 5 |
| [`autoscaling`](us-west-2/autoscaling.csv) | Amazon EC2 Auto Scaling | 9 |
| [`autoscaling-plans`](us-west-2/autoscaling-plans.csv) | AWS Auto Scaling Plans | 3 |
| [`aws-marketplace`](us-west-2/aws-marketplace.csv) | AWS Marketplace | 9 |
| [`aws-mcp`](us-west-2/aws-mcp.csv) | AWS MCP | 13 |
| [`axis`](us-west-2/axis.csv) | sagemaker-geospatial | 2 |
| [`b2bi`](us-west-2/b2bi.csv) | B2B Data Interchange | 4 |
| [`backup`](us-west-2/backup.csv) | AWS Backup | 12 |
| [`batch`](us-west-2/batch.csv) | AWS Batch | 15 |
| [`bedrock`](us-west-2/bedrock.csv) | Amazon Bedrock | 1068 |
| [`bedrock-agentcore`](us-west-2/bedrock-agentcore.csv) | Amazon Bedrock AgentCore | 220 |
| [`bedrock-websearch`](us-west-2/bedrock-websearch.csv) | Amazon Bedrock Web Search | 2 |
| [`braket`](us-west-2/braket.csv) | Amazon Braket | 101 |
| [`cases`](us-west-2/cases.csv) | Amazon Connect Cases | 112 |
| [`cassandra`](us-west-2/cassandra.csv) | Amazon Keyspaces (for Apache Cassandra) | 27 |
| [`chime`](us-west-2/chime.csv) | Amazon Chime | 60 |
| [`cleanrooms`](us-west-2/cleanrooms.csv) | AWS Clean Rooms | 117 |
| [`cleanrooms-ml`](us-west-2/cleanrooms-ml.csv) | AWS Clean Rooms ML | 148 |
| [`cloud9`](us-west-2/cloud9.csv) | AWS Cloud9 | 5 |
| [`cloudformation`](us-west-2/cloudformation.csv) | AWS CloudFormation | 106 |
| [`cloudhsm`](us-west-2/cloudhsm.csv) | AWS CloudHSM | 9 |
| [`cloudshell`](us-west-2/cloudshell.csv) | AWS CloudShell | 4 |
| [`cloudtrail`](us-west-2/cloudtrail.csv) | AWS CloudTrail | 72 |
| [`cloudwatch`](us-west-2/cloudwatch.csv) | Amazon CloudWatch Omni | 69 |
| [`cloudwatchpredictions`](us-west-2/cloudwatchpredictions.csv) | Amazon CloudWatch Anomaly Detection | 1 |
| [`codeartifact`](us-west-2/codeartifact.csv) | AWS CodeArtifact | 17 |
| [`codebuild`](us-west-2/codebuild.csv) | AWS CodeBuild | 38 |
| [`codecatalyst`](us-west-2/codecatalyst.csv) | Amazon CodeCatalyst | 61 |
| [`codecommit`](us-west-2/codecommit.csv) | AWS CodeCommit | 1 |
| [`codedeploy`](us-west-2/codedeploy.csv) | AWS CodeDeploy | 28 |
| [`codeguru-profiler`](us-west-2/codeguru-profiler.csv) | Amazon CodeGuru Profiler | 1 |
| [`codeguru-reviewer`](us-west-2/codeguru-reviewer.csv) | Amazon CodeGuru Reviewer | 1 |
| [`codepipeline`](us-west-2/codepipeline.csv) | AWS CodePipeline | 29 |
| [`cognito-identity`](us-west-2/cognito-identity.csv) | Amazon Cognito Federated Identities | 14 |
| [`cognito-idp`](us-west-2/cognito-idp.csv) | Amazon Cognito User Pools | 31 |
| [`cognito-sync`](us-west-2/cognito-sync.csv) | Amazon Cognito Sync | 5 |
| [`comprehend`](us-west-2/comprehend.csv) | Amazon Comprehend | 82 |
| [`comprehendmedical`](us-west-2/comprehendmedical.csv) | Amazon Comprehend Medical | 41 |
| [`config`](us-west-2/config.csv) | AWS Config | 1 |
| [`connect`](us-west-2/connect.csv) | Amazon Connect | 366 |
| [`connect-campaigns`](us-west-2/connect-campaigns.csv) | Amazon Connect outbound campaigns | 2 |
| [`controltower`](us-west-2/controltower.csv) | AWS Control Tower | 3 |
| [`databrew`](us-west-2/databrew.csv) | AWS Glue DataBrew | 12 |
| [`dataexchange`](us-west-2/dataexchange.csv) | AWS Data Exchange | 32 |
| [`datapipeline`](us-west-2/datapipeline.csv) | AWS Data Pipeline | 13 |
| [`datasync`](us-west-2/datasync.csv) | AWS DataSync | 3 |
| [`datazone`](us-west-2/datazone.csv) | Amazon DataZone | 326 |
| [`dax`](us-west-2/dax.csv) | Amazon DynamoDB Accelerator (DAX) | 5 |
| [`deadline`](us-west-2/deadline.csv) | AWS Deadline Cloud | 32 |
| [`devicefarm`](us-west-2/devicefarm.csv) | AWS Device Farm | 5 |
| [`directconnect`](us-west-2/directconnect.csv) | AWS Direct Connect | 16 |
| [`discovery`](us-west-2/discovery.csv) | AWS Application Discovery Service | 8 |
| [`dlm`](us-west-2/dlm.csv) | Amazon Data Lifecycle Manager | 2 |
| [`dms`](us-west-2/dms.csv) | AWS Database Migration Service (AWS DMS) | 21 |
| [`docdb`](us-west-2/docdb.csv) | Amazon DocumentDB (with MongoDB compatibility) | 10 |
| [`docdb-elastic`](us-west-2/docdb-elastic.csv) | Amazon DocumentDB Elastic Clusters | 5 |
| [`drs`](us-west-2/drs.csv) | ElasticDisasterRecovery | 9 |
| [`ds`](us-west-2/ds.csv) | AWS Directory Service | 6 |
| [`dsql`](us-west-2/dsql.csv) | Amazon Aurora DSQL | 4 |
| [`dynamodb`](us-west-2/dynamodb.csv) | Amazon DynamoDB | 18 |
| [`ebs`](us-west-2/ebs.csv) | Amazon Elastic Block Store (Amazon EBS) | 43 |
| [`ec2`](us-west-2/ec2.csv) | Amazon Elastic Compute Cloud (Amazon EC2) | 1778 |
| [`ec2-ipam`](us-west-2/ec2-ipam.csv) | IPAM | 15 |
| [`ec2fastlaunch`](us-west-2/ec2fastlaunch.csv) | EC2 Fast Launch | 1 |
| [`ecr`](us-west-2/ecr.csv) | Amazon Elastic Container Registry (Amazon ECR) | 23 |
| [`ecs`](us-west-2/ecs.csv) | Amazon Elastic Container Service (Amazon ECS) | 62 |
| [`eks`](us-west-2/eks.csv) | Amazon Elastic Kubernetes Service (Amazon EKS) | 13 |
| [`eks-mcp`](us-west-2/eks-mcp.csv) | Amazon EKS MCP | 2 |
| [`elastic-inference`](us-west-2/elastic-inference.csv) | Amazon Elastic Inference | 1 |
| [`elasticache`](us-west-2/elasticache.csv) | Amazon ElastiCache | 12 |
| [`elasticbeanstalk`](us-west-2/elasticbeanstalk.csv) | AWS Elastic Beanstalk | 5 |
| [`elasticfilesystem`](us-west-2/elasticfilesystem.csv) | Amazon Elastic File System (EFS) | 23 |
| [`elasticloadbalancing`](us-west-2/elasticloadbalancing.csv) | Elastic Load Balancing (ELB) | 31 |
| [`elasticmapreduce`](us-west-2/elasticmapreduce.csv) | Amazon EMR | 98 |
| [`elemental-inference`](us-west-2/elemental-inference.csv) | AWS Elemental Inference | 23 |
| [`emr-containers`](us-west-2/emr-containers.csv) | Amazon EMR on EKS | 42 |
| [`emr-serverless`](us-west-2/emr-serverless.csv) | Amazon EMR Serverless | 2 |
| [`end-user-messaging`](us-west-2/end-user-messaging.csv) | AWS End User Messaging | 3 |
| [`entityresolution`](us-west-2/entityresolution.csv) | AWS Entity Resolution | 13 |
| [`es`](us-west-2/es.csv) | Amazon OpenSearch Service | 5 |
| [`events`](us-west-2/events.csv) | Amazon EventBridge (CloudWatch Events) | 21 |
| [`evidently`](us-west-2/evidently.csv) | Amazon CloudWatch Evidently | 9 |
| [`evs`](us-west-2/evs.csv) | Amazon Elastic VMware Service | 2 |
| [`fargate`](us-west-2/fargate.csv) | AWS Fargate | 6 |
| [`finspace`](us-west-2/finspace.csv) | Amazon FinSpace | 46 |
| [`firehose`](us-west-2/firehose.csv) | Amazon Kinesis Data Firehose | 15 |
| [`fis`](us-west-2/fis.csv) | AWS Fault Injection Service (AWS FIS) | 53 |
| [`fms`](us-west-2/fms.csv) | AWS Firewall Manager | 30 |
| [`forecast`](us-west-2/forecast.csv) | Amazon Forecast | 40 |
| [`frauddetector`](us-west-2/frauddetector.csv) | Amazon Fraud Detector | 19 |
| [`fsx`](us-west-2/fsx.csv) | Amazon FSx | 30 |
| [`gamelift`](us-west-2/gamelift.csv) | Amazon GameLift Servers | 27 |
| [`gameliftstreams`](us-west-2/gameliftstreams.csv) | Amazon GameLift Streams | 46 |
| [`geo`](us-west-2/geo.csv) | Amazon Location Service (Amazon Location) | 86 |
| [`glacier`](us-west-2/glacier.csv) | Amazon Glacier | 8 |
| [`glue`](us-west-2/glue.csv) | AWS Glue | 47 |
| [`grafana`](us-west-2/grafana.csv) | Amazon Managed Grafana | 12 |
| [`greengrass`](us-west-2/greengrass.csv) | AWS IoT Greengrass | 17 |
| [`groundstation`](us-west-2/groundstation.csv) | AWS Ground Station | 10 |
| [`guardduty`](us-west-2/guardduty.csv) | Amazon GuardDuty | 7 |
| [`health-agent`](us-west-2/health-agent.csv) | Amazon Connect Health | 0 |
| [`healthlake`](us-west-2/healthlake.csv) | AWS HealthLake | 76 |
| [`imagebuilder`](us-west-2/imagebuilder.csv) | EC2 Image Builder | 23 |
| [`inspector`](us-west-2/inspector.csv) | Amazon Inspector Classic | 4 |
| [`inspector2`](us-west-2/inspector2.csv) | Amazon Inspector | 1 |
| [`interconnect`](us-west-2/interconnect.csv) | AWS Interconnect | 4 |
| [`internetmonitor`](us-west-2/internetmonitor.csv) | CloudWatch Internet Monitor | 3 |
| [`iot`](us-west-2/iot.csv) | AWS IoT | 179 |
| [`iotcore`](us-west-2/iotcore.csv) | AWS IoT Core | 238 |
| [`iotdeviceadvisor`](us-west-2/iotdeviceadvisor.csv) | AWS IoT Core Device Advisor | 20 |
| [`iotevents`](us-west-2/iotevents.csv) | AWS IoT Events | 26 |
| [`iotsitewise`](us-west-2/iotsitewise.csv) | AWS IoT SiteWise | 97 |
| [`iotthingsgraph`](us-west-2/iotthingsgraph.csv) | AWS IoT Things Graph | 48 |
| [`iottwinmaker`](us-west-2/iottwinmaker.csv) | AWS IoT TwinMaker | 18 |
| [`iotwireless`](us-west-2/iotwireless.csv) | AWS IoT Wireless | 100 |
| [`ivs`](us-west-2/ivs.csv) | Amazon Interactive Video Service | 29 |
| [`ivschat`](us-west-2/ivschat.csv) | Amazon Interactive Video Service Chat | 8 |
| [`kafka`](us-west-2/kafka.csv) | Amazon Managed Streaming for Kafka (MSK) | 7 |
| [`kafkaconnect`](us-west-2/kafkaconnect.csv) | Managed Streaming for Kafka Connect | 3 |
| [`kendra`](us-west-2/kendra.csv) | Amazon Kendra | 28 |
| [`kendra-ranking`](us-west-2/kendra-ranking.csv) | Amazon Kendra Intelligent Ranking | 6 |
| [`kinesis`](us-west-2/kinesis.csv) | Amazon Kinesis Data Streams | 1 |
| [`kinesisanalytics`](us-west-2/kinesisanalytics.csv) | Amazon Managed Service for Apache Flink | 4 |
| [`kinesisvideo`](us-west-2/kinesisvideo.csv) | Amazon Kinesis Video Streams | 98 |
| [`kms`](us-west-2/kms.csv) | AWS Key Management Service (AWS KMS) | 59 |
| [`lakeformation`](us-west-2/lakeformation.csv) | AWS Lake Formation | 7 |
| [`lambda`](us-west-2/lambda.csv) | AWS Lambda | 76 |
| [`launchwizard`](us-west-2/launchwizard.csv) | AWS Launch Wizard | 4 |
| [`lex`](us-west-2/lex.csv) | Amazon Lex | 13 |
| [`license-manager`](us-west-2/license-manager.csv) | AWS License Manager | 25 |
| [`license-manager-linux-subscriptions`](us-west-2/license-manager-linux-subscriptions.csv) | AWS License Manager Linux Subscriptions | 1 |
| [`license-manager-user-subscriptions`](us-west-2/license-manager-user-subscriptions.csv) | AWS License Manager User Subscriptions | 4 |
| [`lightsail`](us-west-2/lightsail.csv) | Amazon Lightsail | 33 |
| [`logs`](us-west-2/logs.csv) | Amazon CloudWatch Logs | 69 |
| [`lookoutvision`](us-west-2/lookoutvision.csv) | Amazon Lookout for Vision | 15 |
| [`m2`](us-west-2/m2.csv) | AWS Mainframe Modernization | 6 |
| [`macie2`](us-west-2/macie2.csv) | Amazon Macie | 25 |
| [`marketplaceagreement`](us-west-2/marketplaceagreement.csv) | AWS Marketplace Agreement Service | 4 |
| [`mediaconnect`](us-west-2/mediaconnect.csv) | AWS Elemental MediaConnect | 10 |
| [`mediaconvert`](us-west-2/mediaconvert.csv) | AWS Elemental MediaConvert | 74 |
| [`medialive`](us-west-2/medialive.csv) | AWS Elemental MediaLive | 24 |
| [`mediapackage`](us-west-2/mediapackage.csv) | AWS Elemental MediaPackage | 22 |
| [`mediapackagev2`](us-west-2/mediapackagev2.csv) | AWS Elemental MediaPackage v2 | 15 |
| [`mediastore`](us-west-2/mediastore.csv) | AWS Elemental MediaStore | 10 |
| [`mediatailor`](us-west-2/mediatailor.csv) | AWS Elemental MediaTailor | 19 |
| [`medical-imaging`](us-west-2/medical-imaging.csv) | AWS Health Imaging | 12 |
| [`memorydb`](us-west-2/memorydb.csv) | Amazon MemoryDB | 8 |
| [`mgn`](us-west-2/mgn.csv) | Application Migration | 19 |
| [`migrationhuborchestrator`](us-west-2/migrationhuborchestrator.csv) | Migration Hub Orchestrator | 3 |
| [`migrationhubstrategy`](us-west-2/migrationhubstrategy.csv) | Migration Hub Strategy Recommendations | 4 |
| [`monitoring`](us-west-2/monitoring.csv) | Amazon CloudWatch | 62 |
| [`mq`](us-west-2/mq.csv) | Amazon MQ | 17 |
| [`neptune`](us-west-2/neptune.csv) | Amazon Neptune | 13 |
| [`neptune-graph`](us-west-2/neptune-graph.csv) | Amazon Neptune Analytics | 25 |
| [`network-firewall`](us-west-2/network-firewall.csv) | AWS Network Firewall | 30 |
| [`network-security-manager`](us-west-2/network-security-manager.csv) | AWS Network Security Manager | 15 |
| [`networkinsights`](us-west-2/networkinsights.csv) | Network Insights | 6 |
| [`networkmonitor`](us-west-2/networkmonitor.csv) | Amazon CloudWatch Network Monitor | 3 |
| [`oam`](us-west-2/oam.csv) | Amazon CloudWatch Observability Access Manager | 18 |
| [`observabilityadmin`](us-west-2/observabilityadmin.csv) | Amazon CloudWatch Observability Admin | 37 |
| [`omics`](us-west-2/omics.csv) | AWS HealthOmics | 26 |
| [`opensearch`](us-west-2/opensearch.csv) | OpenSearch Application | 1 |
| [`outposts`](us-west-2/outposts.csv) | AWS Outposts | 2 |
| [`panorama`](us-west-2/panorama.csv) | AWS Panorama | 21 |
| [`payment-cryptography`](us-west-2/payment-cryptography.csv) | AWS Payment Cryptography | 5 |
| [`pca-connector-ad`](us-west-2/pca-connector-ad.csv) | Private CA Connector for Active Directory | 30 |
| [`pca-connector-scep`](us-west-2/pca-connector-scep.csv) | Private CA Connector for Simple Certificate Enrollment Protocol | 17 |
| [`pcs`](us-west-2/pcs.csv) | AWS Parallel Computing Service | 1 |
| [`personalize`](us-west-2/personalize.csv) | Amazon Personalize | 74 |
| [`pinpoint`](us-west-2/pinpoint.csv) | Amazon Pinpoint | 132 |
| [`polly`](us-west-2/polly.csv) | Amazon Polly | 18 |
| [`private-networks`](us-west-2/private-networks.csv) | AWS Private 5G | 1 |
| [`profile`](us-west-2/profile.csv) | Amazon Connect Customer Profiles | 18 |
| [`proton`](us-west-2/proton.csv) | AWS Proton | 7 |
| [`qapps`](us-west-2/qapps.csv) | Amazon Q Apps | 4 |
| [`qbusiness`](us-west-2/qbusiness.csv) | Amazon Q | 5 |
| [`quicksight`](us-west-2/quicksight.csv) | Amazon QuickSight | 55 |
| [`ram`](us-west-2/ram.csv) | AWS Resource Access Manager | 8 |
| [`rbin`](us-west-2/rbin.csv) | Amazon Recycle Bin | 2 |
| [`rds`](us-west-2/rds.csv) | Amazon Relational Database Service (Amazon RDS) | 28 |
| [`redshift`](us-west-2/redshift.csv) | Amazon Redshift | 29 |
| [`redshift-serverless`](us-west-2/redshift-serverless.csv) | Amazon Redshift Serverless | 3 |
| [`refactor-spaces`](us-west-2/refactor-spaces.csv) | AWS Migration Hub Refactor Spaces | 4 |
| [`rekognition`](us-west-2/rekognition.csv) | Amazon Rekognition | 96 |
| [`repostspace`](us-west-2/repostspace.csv) | AWS re:Post Private | 25 |
| [`resiliencehub`](us-west-2/resiliencehub.csv) | AWS Resilience Hub | 38 |
| [`resource-explorer-2`](us-west-2/resource-explorer-2.csv) | AWS Resource Explorer | 2 |
| [`resource-groups`](us-west-2/resource-groups.csv) | AWS Resource Groups | 1 |
| [`robomaker`](us-west-2/robomaker.csv) | AWS RoboMaker | 24 |
| [`rolesanywhere`](us-west-2/rolesanywhere.csv) | IAM Roles Anywhere | 10 |
| [`route53-recovery-control-config`](us-west-2/route53-recovery-control-config.csv) | Amazon Route 53 Recovery Control Configuration | 5 |
| [`route53-recovery-readiness`](us-west-2/route53-recovery-readiness.csv) | Amazon Route 53 Recovery Readiness | 10 |
| [`route53profiles`](us-west-2/route53profiles.csv) | Route 53 Profiles | 4 |
| [`route53resolver`](us-west-2/route53resolver.csv) | Route 53 Resolver | 13 |
| [`rtbfabric`](us-west-2/rtbfabric.csv) | RTB Fabric | 12 |
| [`rum`](us-west-2/rum.csv) | Amazon CloudWatch RUM | 2 |
| [`s3`](us-west-2/s3.csv) | Amazon Simple Storage Service (Amazon S3) | 20 |
| [`s3-outposts`](us-west-2/s3-outposts.csv) | AWS S3 Outposts | 2 |
| [`s3files`](us-west-2/s3files.csv) | Amazon S3 Files | 2 |
| [`sagemaker`](us-west-2/sagemaker.csv) | Amazon SageMaker | 2418 |
| [`scheduler`](us-west-2/scheduler.csv) | Amazon EventBridge Scheduler | 15 |
| [`schemas`](us-west-2/schemas.csv) | Amazon EventBridge Schema Registry | 5 |
| [`scn`](us-west-2/scn.csv) | Amazon Connect Decisions | 4 |
| [`sdb`](us-west-2/sdb.csv) | Amazon SimpleDB | 18 |
| [`secretsmanager`](us-west-2/secretsmanager.csv) | AWS Secrets Manager | 18 |
| [`security-ir`](us-west-2/security-ir.csv) | Security Incident Response | 25 |
| [`securityagent`](us-west-2/securityagent.csv) | AWS Security Agent | 3 |
| [`securityhub`](us-west-2/securityhub.csv) | AWS Security Hub | 7 |
| [`serverlessrepo`](us-west-2/serverlessrepo.csv) | AWS Serverless Application Repository | 3 |
| [`servicecatalog`](us-west-2/servicecatalog.csv) | AWS Service Catalog | 20 |
| [`servicequotas`](us-west-2/servicequotas.csv) | Service Quotas | 14 |
| [`ses`](us-west-2/ses.csv) | Amazon Simple Email Service(Amazon SES) | 5 |
| [`shield`](us-west-2/shield.csv) | AWS Shield Advanced | 2 |
| [`signer`](us-west-2/signer.csv) | AWS Signer | 19 |
| [`signin`](us-west-2/signin.csv) | AWS IAM Identity Center | 2 |
| [`sms`](us-west-2/sms.csv) | AWS Server Migration Service | 2 |
| [`sms-voice`](us-west-2/sms-voice.csv) | AWS End User Messaging SMS | 16 |
| [`snow-device-management`](us-west-2/snow-device-management.csv) | AWS Snow Device Management | 12 |
| [`snowball`](us-west-2/snowball.csv) | AWS Snow Family | 2 |
| [`sns`](us-west-2/sns.csv) | Amazon Simple Notification Service (Amazon SNS) | 48 |
| [`social-messaging`](us-west-2/social-messaging.csv) | AWS End User Messaging Social | 13 |
| [`sqs`](us-west-2/sqs.csv) | Amazon Simple Queue Service (Amazon SQS) | 18 |
| [`ssm`](us-west-2/ssm.csv) | AWS Systems Manager | 165 |
| [`ssm-contacts`](us-west-2/ssm-contacts.csv) | AWS Systems Manager Incident Manager Contacts | 22 |
| [`ssm-guiconnect`](us-west-2/ssm-guiconnect.csv) | AWS Systems Manager GUI Connect | 5 |
| [`ssm-incidents`](us-west-2/ssm-incidents.csv) | AWS Systems Manager Incident Manager | 36 |
| [`ssm-quicksetup`](us-west-2/ssm-quicksetup.csv) | AWS Systems Manager - Quicksetup | 15 |
| [`ssm-sap`](us-west-2/ssm-sap.csv) | AWS Systems Manager for SAP | 3 |
| [`sso`](us-west-2/sso.csv) | AWS IAM Identity Center (successor to AWS Single Sign-On) | 8 |
| [`states`](us-west-2/states.csv) | AWS Step Functions | 99 |
| [`storagegateway`](us-west-2/storagegateway.csv) | AWS Storage Gateway | 26 |
| [`support`](us-west-2/support.csv) | AWS Support | 3 |
| [`supportauthz`](us-west-2/supportauthz.csv) | AWS Support Authorization | 13 |
| [`swf`](us-west-2/swf.csv) | Amazon Simple Workflow Service | 101 |
| [`textract`](us-west-2/textract.csv) | Amazon Textract | 32 |
| [`thinclient`](us-west-2/thinclient.csv) | Amazon WorkSpaces Thin Client | 1 |
| [`timestream`](us-west-2/timestream.csv) | Amazon Timestream | 31 |
| [`timestream-influxdb`](us-west-2/timestream-influxdb.csv) | Amazon Timestream for InfluxDB | 1 |
| [`tnb`](us-west-2/tnb.csv) | AWS Telco Network Builder | 4 |
| [`transcribe`](us-west-2/transcribe.csv) | Amazon Transcribe | 82 |
| [`transfer`](us-west-2/transfer.csv) | AWS Transfer Family | 34 |
| [`translate`](us-west-2/translate.csv) | Amazon Translate | 3 |
| [`trustedadvisor`](us-west-2/trustedadvisor.csv) | AWS Trusted Advisor | 11 |
| [`ts`](us-west-2/ts.csv) | Diagnostic Tools | 0 |
| [`verifiedpermissions`](us-west-2/verifiedpermissions.csv) | Amazon Verified Permissions | 33 |
| [`vmimportexport`](us-west-2/vmimportexport.csv) | EC2 VM Import/Export | 2 |
| [`voiceid`](us-west-2/voiceid.csv) | Amazon Connect Voice ID | 9 |
| [`vpc`](us-west-2/vpc.csv) | Amazon Virtual Private Cloud (Amazon VPC) | 32 |
| [`vpc-lattice`](us-west-2/vpc-lattice.csv) | VPC Lattice | 17 |
| [`waf-regional`](us-west-2/waf-regional.csv) | AWS WAF Classic (Regional) | 22 |
| [`wafv2`](us-west-2/wafv2.csv) | AWS WAF | 35 |
| [`wam`](us-west-2/wam.csv) | Amazon WorkSpaces Application Manager | 4 |
| [`wellarchitected`](us-west-2/wellarchitected.csv) | AWS Well-Architected Tool | 14 |
| [`wisdom`](us-west-2/wisdom.csv) | Connect AI agent | 69 |
| [`workspaces`](us-west-2/workspaces.csv) | Amazon WorkSpaces | 38 |
| [`workspaces-instances`](us-west-2/workspaces-instances.csv) | Amazon WorkSpaces Managed Instances | 2 |
| [`workspaces-web`](us-west-2/workspaces-web.csv) | Amazon WorkSpaces Secure Browser | 69 |
| [`xray`](us-west-2/xray.csv) | AWS X-Ray | 11 |
<!-- END catalog-index -->
