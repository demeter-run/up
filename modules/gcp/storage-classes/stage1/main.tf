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

resource "kubernetes_storage_class" "fast" {
  metadata {
    name = "fast"
  }

  allow_volume_expansion = true
  storage_provisioner    = "pd.csi.storage.gke.io"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"

  parameters = {
    "type" = "hyperdisk-balanced"
  }
}

resource "kubernetes_storage_class" "hyperdisk-balanced" {
  metadata {
    name = "hyperdisk-balanced"
  }

  allow_volume_expansion = true
  storage_provisioner    = "pd.csi.storage.gke.io"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    "type" = "hyperdisk-balanced"
  }
}

resource "kubernetes_storage_class" "hyperdisk-balanced-immediate" {
  metadata {
    name = "hyperdisk-balanced-immediate"
  }

  allow_volume_expansion = true
  storage_provisioner    = "pd.csi.storage.gke.io"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"

  parameters = {
    "type" = "hyperdisk-balanced"
  }
}
