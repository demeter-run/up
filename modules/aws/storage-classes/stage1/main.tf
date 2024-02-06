resource "kubernetes_storage_class" "gp" {
  metadata {
    name = "gp"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "kubernetes.io/aws-ebs"

  parameters = {
    fsType = "ext4"
    type   = "gp3"
  }

  reclaim_policy = "Delete"

  volume_binding_mode = "WaitForFirstConsumer"
}
