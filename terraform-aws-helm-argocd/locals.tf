locals {
  normalized_in_cluster_name = trimprefix(trimsuffix(tostring(var.in_cluster_name), "\""), "\"")

  node_selectors = flatten([
    for key, value in var.node_selector : {
      key   = key
      value = value
    }
  ])

  in_clusters = compact(distinct([
    "in-cluster",
    var.enabled_managed_in_cluster ? local.normalized_in_cluster_name : null,
  ]))

  dex_connectors = concat(
    [
      {
        type = "github"
        id   = "github"
        name = "GitHub"
        config = {
          clientID     = var.oidc_github_client_id
          clientSecret = var.oidc_github_client_secret
          orgs = [
            {
              name = var.oidc_github_organization
            }
          ]
        }
      }
    ],
    [
      for key, creds in var.external_github_oauth_creds : {
        type = "github"
        id   = "github-${key}"
        name = "Github ${key}"
        config = {
          clientID     = creds.client_id
          clientSecret = "$github-oauth-${key}:dex.${key}.clientSecret"
          orgs = [
            {
              name = key
            }
          ]
        }
      }
    ]
  )

  cluster_credentials = merge(
    {
      for cluster in local.in_clusters : cluster => {
        server           = "https://kubernetes.default.svc"
        annotations      = {}
        labels           = {}
        clusterResources = false
        config = {
          tlsClientConfig = {
            insecure = false
          }
        }
      }
    },
    {
      for key, cluster in var.external_clusters : key => merge(
        {
          server = cluster.server
          config = {
            awsAuthConfig = {
              clusterName = cluster.config.aws_auth_config.cluster_name
              roleARN     = cluster.config.aws_auth_config.role_arn
            }
            tlsClientConfig = {
              insecure = try(tobool(cluster.config.tls_client_config.insecure), false)
              caData   = cluster.config.tls_client_config.ca_data
            }
          }
        },
        length(cluster.annotations) > 0 ? { annotations = cluster.annotations } : {},
        length(cluster.labels) > 0 ? { labels = cluster.labels } : {},
        # Keep bool and string attributes in separate conditional maps so Terraform does not coerce bools to strings.
        try(tobool(cluster.cluster_resources), false) ? {
          clusterResources = tobool(cluster.cluster_resources)
        } : {},
        try(tobool(cluster.cluster_resources), false) ? {
          namespace = cluster.namespace
        } : {}
      )
    }
  )

  # Merge conditional sections so disabled blocks disappear instead of encoding as null or empty.
  manifest = yamlencode({
    global = merge(
      {
        domain = "${var.sub_domain}.${var.domain_name}"
      },
      length(local.node_selectors) > 0 ? {
        nodeSelector = var.node_selector
      } : {},
      length(var.tolerations) > 0 ? {
        tolerations = [
          for toleration in var.tolerations : {
            key      = toleration.key
            operator = toleration.operator
            value    = toleration.value
            effect   = toleration.effect
          }
        ]
      } : {}
    )
    server = {
      ingress = {
        enabled          = true
        hostname         = "${var.sub_domain}.${var.domain_name}"
        ingressClassName = var.ingress_class_name
        controller       = "aws"
        annotations = {
          "alb.ingress.kubernetes.io/group.name"   = var.ingress_group_name
          "kubernetes.io/ingress.class"            = var.ingress_class_name
          "alb.ingress.kubernetes.io/target-type"  = "ip"
          "alb.ingress.kubernetes.io/scheme"       = var.ingress_scheme
          "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\": 443}]"
        }
        path     = "/"
        pathType = "Prefix"
      }
    }
    dex = {
      enabled = true
    }
    configs = {
      params = {
        "server.insecure"             = !var.handle_tls
        "controller.diff.server.side" = tostring(var.server_side_diff)
      }
      cm = {
        "dex.config" = yamlencode({
          connectors = local.dex_connectors
          issuer     = var.issuer_url
        })
      }
      rbac = {
        "policy.csv" = join("\n", var.rbac_policies)
      }
      clusterCredentials = local.cluster_credentials
    }
    notifications = local.notifications_values
  })
}
