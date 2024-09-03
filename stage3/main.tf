terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
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

# Placeholder/Replacement storage class for kupo, utxorpc instead of using the nvme storage class by default
resource "kubernetes_storage_class_v1" "gp_immediate" {
  for_each = toset([for t in toset(["gp-immediate"]) : t if var.cloud_provider == "gcp" || var.cloud_provider == "aws"])
  metadata {
    name = "gp-immediate"
  }

  storage_provisioner = var.cloud_provider == "gcp" ? "pd.csi.storage.gke.io" : "kubernetes.io/aws-ebs"
  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"

  allow_volume_expansion = true

  parameters = var.cloud_provider == "gcp" ? {
    type = "pd-balanced"
    } : {
    type      = "gp3"
    fsType    = "ext4"
    encrypted = "true"
  }
}
