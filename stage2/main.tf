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

# module "cert_manager" {
#   source = "../modules/cert-manager/stage2"
# }

# module "grafana_tempo" {
#   source    = "../modules/grafana-tempo/stage2"
#   namespace = var.dmtr_namespace
# }

# module "postgresql" {
#   source = "../modules/postgresql/stage2"
# }

module "o11y" {
  source    = "../modules/common/o11y/stage2"
  namespace = var.dmtr_namespace
}

module "dmtrd" {
  source        = "../modules/common/dmtrd/stage2"
  namespace     = var.dmtr_namespace
  dmtrd_version = var.dmtrd_version
}
