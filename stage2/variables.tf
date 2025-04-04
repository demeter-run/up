variable "k8s_config" {
  description = "the location of the k8s configuration"
  default     = "~/.kube/config"
}

variable "k8s_context" {
  description = "the name of the k8s context as defined in the kube config file"
}

// Ingress class to use for cert-manager
variable "cloud_provider" {
  default = "gcp"
}

// Email to use for the ACME account
variable "acme_account_email" {
  default = "something@example.com"
}

variable "cloudflare_token" {
  type        = string
  description = <<EOF
Optional Cloudflare API token.
If provided, will use Cloudflare for DNS challenges.
Otherwise, it defaults to AWS Route53.
EOF
}

// Configuration for decentrelized Demeter daemon
variable "dmtr_namespace" {
  description = "the namespace where to install Demeter's system"
  default     = "dmtr-system"
}

variable "dmtrd_version" {
  description = "version of the Demeter daemon to deploy"
  default     = "99e71e3af72f6c734b82535052822a89f59921ee"
}

variable "dmtrd_cluster_id" {
  type        = string
  description = "ID for the cluster. Contact Demeter team for this information."
}

variable "dmtrd_broker_urls" {
  type        = string
  description = "Comma separated list of queue brokers. Contact Demeter team for this information."
}

variable "dmtrd_kafka_username" {
  type        = string
  description = "Queue username. Contact Demeter team for this information."
}

variable "dmtrd_kafka_password" {
  type        = string
  description = "Queue password. Contact Demeter team for this information."
}

variable "dmtrd_consumer_monitor_name" {
  type        = string
  description = "Name of queue consumer for monitor process, should be unique per cluster. Contact Demeter team for this information."
}

variable "dmtrd_consumer_cache_name" {
  type        = string
  description = "Name of queue consumer for cache process, should be unique per cluster. Contact Demeter team for this information."
}

variable "dmtrd_kafka_topic_events" {
  type        = string
  default     = "events"
  description = "Name of topic to consume from. Contact Demeter team for this information."
}

variable "dmtrd_kafka_topic_usage" {
  type        = string
  default     = "usage"
  description = "Name of topic to consume from. Contact Demeter team for this information."
}

variable "dmtrd_replicas" {
  type        = number
  default     = 1
  description = "Amount of Demeter daemon replicas."
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
