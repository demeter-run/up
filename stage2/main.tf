terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}

provider "kubernetes" {
  config_path    = var.k8s_config
  config_context = var.k8s_context
}

provider "helm" {
  kubernetes {
    config_path    = var.k8s_config
    config_context = var.k8s_context
  }
}

locals {
  acme_account_email = try(var.acme_account_email, null)
  ingress_classes = {
    "aws" = "alb"
    "gcp" = "gce"
  }
}

module "cert_manager" {
  source             = "../modules/common/cert-manager/stage2"
  acme_account_email = local.acme_account_email
  cloudflare_token   = var.cloudflare_token
}

# module "grafana_tempo" {
#   source    = "../modules/grafana-tempo/stage2"
#   namespace = var.dmtr_namespace
# }

# module "postgresql" {
#   source = "../modules/postgresql/stage2"
# }

module "o11y" {
  source              = "../modules/common/o11y/stage2"
  namespace           = var.dmtr_namespace
  storage_class       = var.cloud_provider == "gcp" ? "hyperdisk-balanced" : "gp"
  enable_grafana      = var.enable_grafana
  enable_alertmanager = var.enable_alertmanager
}

module "dmtrd" {
  source = "../modules/common/dmtrd/stage2"

  namespace             = var.dmtr_namespace
  cluster_id            = var.dmtrd_cluster_id
  image_tag             = var.dmtrd_version
  broker_urls           = var.dmtrd_broker_urls
  kafka_username        = var.dmtrd_kafka_username
  kafka_password        = var.dmtrd_kafka_password
  consumer_monitor_name = var.dmtrd_consumer_monitor_name
  consumer_cache_name   = var.dmtrd_consumer_cache_name
  kafka_topic_events    = var.dmtrd_kafka_topic_events
  kafka_topic_usage     = var.dmtrd_kafka_topic_usage
  replicas              = var.dmtrd_replicas
}
