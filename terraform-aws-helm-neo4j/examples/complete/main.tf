module "neo4j" {
  source = "../.."

  efs_id = "example-id"
  domain = "example.com"

  neo4j_plugins = [
    "https://github.com/neo4j/graph-data-science/releases/download/2.13.2/neo4j-graph-data-science-2.13.2.jar",
    "https://github.com/neo4j/apoc/releases/download/5.26.0/apoc-5.26.0-core.jar"
  ]

  node_selector = {}
  tolerations   = []
}
