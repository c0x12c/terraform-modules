output "cluster_agent_auth_token" {
  description = "The auth token for the cluster agent"
  value       = random_password.cluster_agent_token.result
}
