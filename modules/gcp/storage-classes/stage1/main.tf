resource "kubernetes_storage_class" "gp" {
  metadata {
    name = "gp"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  allow_volume_expansion = true
  storage_provisioner    = "pd.csi.storage.gke.io"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    "type" = "pd-balanced"
  }
}
