terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}

locals {
  cluster_name          = "dmtr-xxx"
  k8s_config            = "~/.kube/config"
  k8s_context           = "mycontext"
  cluster_alias         = "us1"
  dns_zone              = "demeter.run"
  full_dns_zone         = "${local.cluster_name}.${local.dns_zone}"
  dmtr_system_namespace = "dmtr-system"
  dns_names             = ["*.${local.cluster_alias}.demeter.run", "*.${local.cluster_name}.demeter.run"]
}

provider "kubernetes" {
  config_path    = local.k8s_config
  config_context = local.k8s_context
}

provider "helm" {
  kubernetes {
    config_path    = local.k8s_config
    config_context = local.k8s_context
  }
}

resource "kubernetes_namespace" "dmtr_system_namespace" {
  metadata {
    name = local.dmtr_system_namespace
  }
}

module "cert_manager" {
  source = "../modules/cert-manager/stage2"
}

module "dmtrd" {
  source    = "../modules/dmtrd/stage2"
  namespace = local.dmtr_system_namespace
}

module "grafana_tempo" {
  source = "../modules/grafana-tempo/stage2"
}

module "o11y" {
  source = "../modules/o11y/stage2"
}

module "postgresql" {
  source = "../modules/postgresql/stage2"
}
