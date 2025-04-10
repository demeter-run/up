variable "namespace" {
  description = "the namespace where to install Demeter's system"
  default     = "dmtr-system"
}

variable "image_tag" {
  description = "version of the Demeter daemon to deploy"
  default     = "bb23443d393f5a31b4c9e88dfdd891f68df76f7d"
}

variable "cluster_id" {
  description = "ID for the cluster where the daemon runs."
  type        = string
}

variable "broker_urls" {
  type        = string
  description = "Comma separated list of queue brokers. Contact Demeter team for this information."
}

variable "kafka_username" {
  type        = string
  description = "Queue username. Contact Demeter team for this information."
}

variable "kafka_password" {
  type        = string
  description = "Queue password. Contact Demeter team for this information."
}

variable "consumer_monitor_name" {
  type        = string
  description = "Name of queue consumer for monitor process, should be unique per cluster. Contact Demeter team for this information."
}

variable "consumer_cache_name" {
  type        = string
  description = "Name of queue consumer for cache process, should be unique per cluster. Contact Demeter team for this information."
}

variable "kafka_topic_events" {
  type        = string
  default     = "events"
  description = "Name of topic to consume events from. Contact Demeter team for this information."
}

variable "kafka_topic_usage" {
  type        = string
  default     = "usage"
  description = "Name of topic to consume usage from. Contact Demeter team for this information."
}

variable "replicas" {
  type        = number
  default     = 1
  description = "Amount of Demeter daemon replicas."
}

module "dmtr_daemon" {
  source = "git::https://github.com/demeter-run/fabric.git//bootstrap/daemon?ref=8d6d43aed226cb542465e834bfed61bf5cb2c750"

  namespace             = var.namespace
  image                 = "ghcr.io/demeter-run/fabric-daemon:${var.image_tag}"
  broker_urls           = var.broker_urls
  consumer_monitor_name = var.consumer_monitor_name
  consumer_cache_name   = var.consumer_cache_name
  kafka_username        = var.kafka_username
  kafka_password        = var.kafka_password
  kafka_topic_events    = var.kafka_topic_events
  kafka_topic_usage     = var.kafka_topic_usage
  replicas              = var.replicas
  cluster_id            = var.cluster_id
  prometheus_url        = "http://prometheus-operated.${var.namespace}.svc.cluster.local:9090/api/v1"
  tolerations = [
    {
      effect   = "NoSchedule"
      key      = "demeter.run/compute-profile"
      operator = "Equal"
      value    = "general-purpose"
    },
    {
      effect   = "NoSchedule"
      key      = "demeter.run/compute-arch"
      operator = "Equal"
      value    = "x86"
    },
    {
      effect   = "NoSchedule"
      key      = "demeter.run/availability-sla"
      operator = "Equal"
      value    = "consistent"
    }

  ]
}
