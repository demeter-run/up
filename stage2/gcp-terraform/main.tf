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
  source        = "../../modules/common/o11y/stage2"
  namespace     = var.dmtr_namespace
  storage_class = "standard"
  depends_on    = [kubernetes_resource_quota.critical_pods_quota]
}

module "dmtrd" {
  source        = "../../modules/common/dmtrd/stage2"
  namespace     = var.dmtr_namespace
  dmtrd_version = var.dmtrd_version
}

resource "kubernetes_resource_quota" "critical_pods_quota" {
  metadata {
    name      = "critical-pods-quota"
    namespace = "dmtr-system"
  }

  spec {
    scope_selector {
      match_expression {
        operator   = "In"
        scope_name = "PriorityClass"
        values     = ["system-cluster-critical"]
      }
    }
  }
}
