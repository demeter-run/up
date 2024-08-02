variable "k8s_config" {
  description = "the location of the k8s configuration"
  default     = "~/.kube/config"
}

variable "k8s_context" {
  description = "the name of the k8s context as defined in the kube config file"
}

variable "dmtr_namespace" {
  description = "the namespace where to install Demeter's system"
  default     = "dmtr-system"
}

variable "dmtrd_version" {
  description = "version of the Demeter daemon to deploy"
  default     = "682dc9e69443091112adddad31c01625fcde4a6e"
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

variable "dmtrd_consumer_name" {
  type        = string
  description = "Name of queue consumer, should be unique per cluster. Contact Demeter team for this information."
}

variable "dmtrd_kafka_topic" {
  type        = string
  default     = "events"
  description = "Name of topic to consume from. Contact Demeter team for this information."
}

variable "dmtrd_replicas" {
  type        = number
  default     = 1
  description = "Amount of Demeter daemon replicas."
}

// Ingress class to use for cert-manager
variable "cloud_provider" {
  default = "gcp"
}

// Email to use for the ACME account
variable "acme_account_email" {
  default = "something@example.com"
}
