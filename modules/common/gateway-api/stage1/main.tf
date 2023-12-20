terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}

locals {
  crd_files = fileset("${path.module}/manifests/", "*")
  crds      = toset([for f in local.crd_files : file("${path.module}/manifests/${f}")])
}

resource "kubernetes_manifest" "gateway_crds" {
  for_each = local.crds
  manifest = yamldecode(each.value)
}
