resource "kubernetes_manifest" "storage_class_gp" {
  manifest = {
    "apiVersion" = "storage.k8s.io/v1"
    "kind"       = "StorageClass"
    "metadata" = {
      "name" : "gp"
    }
    "provisioner"       = "rancher.io/local-path"
    "reclaimPolicy"     = "Delete"
    "volumeBindingMode" = "WaitForFirstConsumer"
  }
}

