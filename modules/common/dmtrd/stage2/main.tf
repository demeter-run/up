variable "namespace" {
  description = "the namespace where to install Demeter's system"
  default     = "dmtr-system"
}

variable "image_tag" {
  description = "version of the Demeter daemon to deploy"
  default     = "8ce629cc9151284b102252da584f0338c25063cd"
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

variable "consumer_name" {
  type        = string
  description = "Name of queue consumer, should be unique per cluster. Contact Demeter team for this information."
}

variable "kafka_topic" {
  type        = string
  default     = "events"
  description = "Name of topic to consume from. Contact Demeter team for this information."
}

variable "replicas" {
  type        = number
  default     = 1
  description = "Amount of Demeter daemon replicas."
}

module "dmtr_daemon" {
  source = "git::https://github.com/demeter-run/fabric.git//bootstrap/daemon"

  namespace      = var.namespace
  image          = "ghcr.io/demeter-run/fabric-daemon:${var.image_tag}"
  broker_urls    = var.broker_urls
  consumer_name  = var.consumer_name
  kafka_username = var.kafka_username
  kafka_password = var.kafka_password
  kafka_topic    = var.kafka_topic
  replicas       = var.replicas
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
      value    = "best-effort"
    }

  ]
}
