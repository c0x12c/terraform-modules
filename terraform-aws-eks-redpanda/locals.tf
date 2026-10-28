locals {
  # Cheapest first. Memory leaves room for the kubelet and system pods on the node.
  profiles = {
    small = {
      replicas       = 3
      cpu_cores      = 1
      memory         = "2.5Gi"
      storage_type   = "ebs"
      storage_size   = "50Gi"
      instance_types = ["m7g.large"]
    }
    medium = {
      replicas       = 3
      cpu_cores      = 3
      memory         = "24Gi"
      storage_type   = "local_nvme"
      storage_size   = null
      instance_types = ["i4g.xlarge"]
    }
    large = {
      replicas       = 3
      cpu_cores      = 7
      memory         = "52Gi"
      storage_type   = "local_nvme"
      storage_size   = null
      instance_types = ["i4g.2xlarge"]
    }
  }

  profile = local.profiles[var.size]
  brokers = {
    replicas       = coalesce(var.brokers.replicas, local.profile.replicas)
    cpu_cores      = coalesce(var.brokers.cpu_cores, local.profile.cpu_cores)
    memory         = coalesce(var.brokers.memory, local.profile.memory)
    storage_type   = coalesce(var.brokers.storage_type, local.profile.storage_type)
    storage_size   = try(coalesce(var.brokers.storage_size, local.profile.storage_size), "50Gi")
    storage_class  = var.brokers.storage_class
    instance_types = coalesce(var.brokers.instance_types, local.profile.instance_types)
  }
  local_nvme = local.brokers.storage_type == "local_nvme"

  aws_name        = "${var.eks_cluster_name}-${var.name}"
  host_path       = "/mnt/redpanda"
  service_account = var.name
  brokers_address = "${var.name}.${var.namespace}.svc.cluster.local:9093"

  superusers_secret = "${var.name}-superusers"
  admin_secret      = "${var.name}-admin"
  tenant_secrets    = { for k, _ in var.tenants : k => "${var.name}-tenant-${k}" }

  node_taint = merge(var.node_group.taint == null ? { key = "dedicated", value = var.name } : var.node_group.taint, { effect = "NoSchedule" })
  node_label = var.node_group.labels == null ? { "redpanda.com/cluster" = var.name } : var.node_group.labels

  tiered_bucket = var.tiered_storage.enabled ? coalesce(var.tiered_storage.bucket_name, try(aws_s3_bucket.tiered[0].bucket, null)) : null

  cluster_config = merge(
    {
      default_topic_replications = 3
      auto_create_topics_enabled = false
    },
    [{ retention_local_target_bytes_default = var.tiered_storage.local_retention_bytes }, {}][var.tiered_storage.enabled && var.tiered_storage.local_retention_bytes != null ? 0 : 1],
    var.cluster_config,
  )

  tenant_acls = {
    for k, t in var.tenants : k => concat(
      [
        {
          type       = "allow"
          resource   = { type = "topic", name = "${k}.", patternType = "prefixed" }
          operations = ["Read", "Write", "Describe"]
        },
        {
          type       = "allow"
          resource   = { type = "group", name = "${k}.", patternType = "prefixed" }
          operations = ["Read", "Describe"]
        },
      ],
      t.transactions ? [{
        type       = "allow"
        resource   = { type = "transactionalId", name = "${k}.", patternType = "prefixed" }
        operations = ["Write", "Describe"]
      }] : [],
      t.extra_acls,
    )
  }

  topics = merge([
    for k, t in var.tenants : {
      for tn, topic in t.topics : "${k}.${tn}" => {
        partitions         = topic.partitions
        replication_factor = topic.replication_factor
        config             = topic.config
      }
    }
  ]...)

  quotas = [
    for k, t in var.tenants : {
      user               = k
      producer_byte_rate = t.producer_byte_rate
      consumer_byte_rate = t.consumer_byte_rate
    } if t.producer_byte_rate != null || t.consumer_byte_rate != null
  ]

  # Conditionals between differently shaped objects index a tuple, which Terraform allows.
  storage_values = [
    {
      hostPath         = local.host_path
      persistentVolume = { enabled = false }
    },
    {
      persistentVolume = merge(
        { enabled = true, size = local.brokers.storage_size },
        [{ storageClass = local.brokers.storage_class }, {}][local.brokers.storage_class != null ? 0 : 1],
      )
    },
  ][local.local_nvme ? 0 : 1]

  tiered_values = [{
    tiered = {
      config = {
        cloud_storage_enabled            = true
        cloud_storage_region             = data.aws_region.current.region
        cloud_storage_bucket             = local.tiered_bucket
        cloud_storage_credentials_source = "sts"
      }
    }
  }, {}][var.tiered_storage.enabled ? 0 : 1]

  scheduling = {
    nodeSelector = local.node_label
    tolerations = [{
      key      = local.node_taint.key
      operator = "Equal"
      value    = local.node_taint.value
      effect   = local.node_taint.effect
    }]
  }

  cluster_spec = merge(
    {
      image     = { repository = "docker.redpanda.com/redpandadata/redpanda", tag = var.redpanda_version }
      tls       = { enabled = var.tls_enabled }
      external  = { enabled = false }
      listeners = { kafka = { authenticationMethod = "sasl" } }
      auth = {
        sasl = {
          enabled   = true
          mechanism = "SCRAM-SHA-512"
          secretRef = local.superusers_secret
          users     = []
        }
      }
      statefulset = merge(
        { replicas = local.brokers.replicas },
        local.scheduling,
        # hostPath directories are created as root; the broker runs as uid 101.
        [{ initContainers = { setDataDirOwnership = { enabled = true } } }, {}][local.local_nvme ? 0 : 1],
      )
      resources = {
        cpu    = { cores = local.brokers.cpu_cores, overprovisioned = local.brokers.cpu_cores < 2 }
        memory = { container = { max = local.brokers.memory } }
      }
      storage       = merge(local.storage_values, local.tiered_values)
      rackAwareness = { enabled = var.rack_awareness, nodeAnnotation = "topology.kubernetes.io/zone" }
      rbac          = { enabled = var.rack_awareness }
      serviceAccount = merge(
        { create = true, name = local.service_account },
        [{ annotations = { "eks.amazonaws.com/role-arn" = try(aws_iam_role.tiered[0].arn, "") } }, {}][var.tiered_storage.enabled ? 0 : 1],
      )
      # Without an Enterprise licence Console has no login, so it cannot impersonate the viewer and
      # refuses to start. The operator already wires it to Kafka as its own bootstrap user.
      console = {
        enabled = var.console_enabled
        # console.console is Console's own config file; the chart defaults every backend to impersonation.
        console = {
          kafka          = { sasl = { impersonateUser = false } }
          redpanda       = { adminApi = { authentication = { impersonateUser = false } } }
          schemaRegistry = { authentication = { impersonateUser = false } }
        }
        # The operator rewrites adminApi.authentication after merging values and forces
        # impersonation on; Console's env overrides its config file, so pin it off here.
        extraEnv = [{ name = "REDPANDA_ADMINAPI_AUTHENTICATION_IMPERSONATEUSER", value = "false" }]
      }
      config = { cluster = local.cluster_config }
    },
    [{
      enterprise = { licenseSecretRef = { name = try(var.enterprise_license_secret.name, ""), key = try(var.enterprise_license_secret.key, "") } }
    }, {}][var.enterprise_license_secret != null ? 0 : 1],
  )
}

data "aws_region" "current" {}
