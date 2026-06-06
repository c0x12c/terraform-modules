locals {

  enabled_services = [
    for svc in local.datadog_services : {
      id       = svc.id
      disabled = contains(var.enabled_services, svc.id) ? false : true
    }
  ]

  datadog_services = [
    {
      "id" : "actions",
      "disabled" : true
    },
    {
      "id" : "aiplatform",
      "disabled" : true
    },
    {
      "id" : "alloydb",
      "disabled" : true
    },
    {
      "id" : "apigateway",
      "disabled" : true
    },
    {
      "id" : "apigee",
      "disabled" : true
    },
    {
      "id" : "appengine",
      "disabled" : true
    },
    {
      "id" : "apphub",
      "disabled" : true
    },
    {
      "id" : "artifactregistry",
      "disabled" : true
    },
    {
      "id" : "autoscaler",
      "disabled" : true
    },
    {
      "id" : "backupdr",
      "disabled" : true
    },
    {
      "id" : "baremetalsolution",
      "disabled" : true
    },
    {
      "id" : "bigquery",
      "disabled" : true
    },
    {
      "id" : "bigquerybiengine",
      "disabled" : true
    },
    {
      "id" : "bigquerydatatransfer",
      "disabled" : true
    },
    {
      "id" : "bigquerystorage",
      "disabled" : true
    },
    {
      "id" : "bigtable",
      "disabled" : true
    },
    {
      "id" : "billingbudgets",
      "disabled" : true
    },
    {
      "id" : "blockchainnodeengine",
      "disabled" : true
    },
    {
      "id" : "certificatemanager",
      "disabled" : true
    },
    {
      "id" : "chronicle",
      "disabled" : true
    },
    {
      "id" : "clouddeploy",
      "disabled" : true
    },
    {
      "id" : "cloudfunctions",
      "disabled" : true
    },
    {
      "id" : "cloudkms",
      "disabled" : true
    },
    {
      "id" : "cloudsql",
      "disabled" : true
    },
    {
      "id" : "cloudtasks",
      "disabled" : true
    },
    {
      "id" : "cloudtrace",
      "disabled" : true
    },
    {
      "id" : "composer",
      "disabled" : true
    },
    {
      "id" : "compute",
      "disabled" : true
    },
    {
      "id" : "connectors",
      "disabled" : true
    },
    {
      "id" : "contactcenterinsights",
      "disabled" : true
    },
    {
      "id" : "container",
      "disabled" : true
    },
    {
      "id" : "custom",
      "disabled" : true
    },
    {
      "id" : "dataflow",
      "disabled" : true
    },
    {
      "id" : "datamigration",
      "disabled" : true
    },
    {
      "id" : "dataplex",
      "disabled" : true
    },
    {
      "id" : "dataproc",
      "disabled" : true
    },
    {
      "id" : "datastore",
      "disabled" : true
    },
    {
      "id" : "datastream",
      "disabled" : true
    },
    {
      "id" : "dbinsights",
      "disabled" : true
    },
    {
      "id" : "dialogflow",
      "disabled" : true
    },
    {
      "id" : "displayvideo",
      "disabled" : true
    },
    {
      "id" : "dlp",
      "disabled" : true
    },
    {
      "id" : "dns",
      "disabled" : true
    },
    {
      "id" : "earthengine",
      "disabled" : true
    },
    {
      "id" : "edgecache",
      "disabled" : true
    },
    {
      "id" : "edgecontainer",
      "disabled" : true
    },
    {
      "id" : "external",
      "disabled" : true
    },
    {
      "id" : "file",
      "disabled" : true
    },
    {
      "id" : "firebaseappcheck",
      "disabled" : true
    },
    {
      "id" : "firebaseauth",
      "disabled" : true
    },
    {
      "id" : "firebasedatabase",
      "disabled" : true
    },
    {
      "id" : "firebasedataconnect",
      "disabled" : true
    },
    {
      "id" : "firebaseextensions",
      "disabled" : true
    },
    {
      "id" : "firebasehosting",
      "disabled" : true
    },
    {
      "id" : "firebasestorage",
      "disabled" : true
    },
    {
      "id" : "firestore",
      "disabled" : true
    },
    {
      "id" : "firewallinsights",
      "disabled" : true
    },
    {
      "id" : "fleetengine",
      "disabled" : true
    },
    {
      "id" : "gkebackup",
      "disabled" : true
    },
    {
      "id" : "healthcare",
      "disabled" : true
    },
    {
      "id" : "iam",
      "disabled" : true
    },
    {
      "id" : "identitytoolkit",
      "disabled" : true
    },
    {
      "id" : "ids",
      "disabled" : true
    },
    {
      "id" : "integrations",
      "disabled" : true
    },
    {
      "id" : "interconnect",
      "disabled" : true
    },
    {
      "id" : "kubernetes",
      "disabled" : true
    },
    {
      "id" : "livestream",
      "disabled" : true
    },
    {
      "id" : "loadbalancing",
      "disabled" : true
    },
    {
      "id" : "logging",
      "disabled" : true
    },
    {
      "id" : "managedflink",
      "disabled" : true
    },
    {
      "id" : "managedidentities",
      "disabled" : true
    },
    {
      "id" : "managedkafka",
      "disabled" : true
    },
    {
      "id" : "maps",
      "disabled" : true
    },
    {
      "id" : "memcache",
      "disabled" : true
    },
    {
      "id" : "memorystore",
      "disabled" : true
    },
    {
      "id" : "metastore",
      "disabled" : true
    },
    {
      "id" : "ml",
      "disabled" : true
    },
    {
      "id" : "monitoring",
      "disabled" : true
    },
    {
      "id" : "netapp",
      "disabled" : true
    },
    {
      "id" : "networkconnectivity",
      "disabled" : true
    },
    {
      "id" : "networking",
      "disabled" : true
    },
    {
      "id" : "networksecurity",
      "disabled" : true
    },
    {
      "id" : "networkservices",
      "disabled" : true
    },
    {
      "id" : "oracledatabase",
      "disabled" : true
    },
    {
      "id" : "osconfig",
      "disabled" : true
    },
    {
      "id" : "parallelstore",
      "disabled" : true
    },
    {
      "id" : "privateca",
      "disabled" : true
    },
    {
      "id" : "prometheus",
      "disabled" : true
    },
    {
      "id" : "pubsub",
      "disabled" : true
    },
    {
      "id" : "pubsublite",
      "disabled" : true
    },
    {
      "id" : "recaptchaenterprise",
      "disabled" : true
    },
    {
      "id" : "recommendationengine",
      "disabled" : true
    },
    {
      "id" : "redis",
      "disabled" : true
    },
    {
      "id" : "retail",
      "disabled" : true
    },
    {
      "id" : "router",
      "disabled" : true
    },
    {
      "id" : "run",
      "disabled" : true
    },
    {
      "id" : "serviceruntime",
      "disabled" : true
    },
    {
      "id" : "spanner",
      "disabled" : true
    },
    {
      "id" : "storage",
      "disabled" : true
    },
    {
      "id" : "storagetransfer",
      "disabled" : true
    },
    {
      "id" : "telcoautomation",
      "disabled" : true
    },
    {
      "id" : "tpu",
      "disabled" : true
    },
    {
      "id" : "trafficdirector",
      "disabled" : true
    },
    {
      "id" : "transferappliance",
      "disabled" : true
    },
    {
      "id" : "translationhub",
      "disabled" : true
    },
    {
      "id" : "videostitcher",
      "disabled" : true
    },
    {
      "id" : "visionai",
      "disabled" : true
    },
    {
      "id" : "vpcaccess",
      "disabled" : true
    },
    {
      "id" : "vpn",
      "disabled" : true
    },
    {
      "id" : "workflows",
      "disabled" : true
    },
    {
      "id" : "workload",
      "disabled" : true
    }
  ]
}