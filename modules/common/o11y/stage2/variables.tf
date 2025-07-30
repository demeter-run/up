variable "namespace" {
  description = "namespace where to install resources"
}

variable "storage_class" {
  description = "storage class name to use for workload PVCs"
  default     = "gp"
}

variable "enable_grafana" {
  description = "Flag to enable or disable Grafana installation"
  type        = bool
  default     = false
}

variable "enable_alertmanager" {
  description = "Flag to enable or disable Alertmanager installation"
  type        = bool
  default     = false
}

variable "cluster_id" {
  description = "Name of the cluster to add as a label to all metrics"
  type        = string
  default     = ""
}
