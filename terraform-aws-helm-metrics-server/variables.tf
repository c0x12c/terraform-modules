variable "namespace" {
  description = "The Namespace of the services."
  type        = string
  default     = "kube-system"
}
variable "helm_release_name" {
  description = "The Helm release of the services."
  type        = string
  default     = "metrics-server"
}

variable "helm_chart_version" {
  default     = "3.12.2"
  type        = string
  description = "The chart version of metrics server"
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for the metrics server"
  default     = {}
}

variable "tolerations" {
  type        = list(map(string))
  description = "Tolerations for the metrics server"
  default     = []
}
