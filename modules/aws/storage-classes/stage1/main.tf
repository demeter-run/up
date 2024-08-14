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

resource "kubernetes_storage_class_v1" "fast" {
  metadata {
    name = "fast"
  }
  parameters = {
    type       = "gp3"
    iops       = "5000"
    throughput = "300"
  }

  volume_binding_mode = "WaitForFirstConsumer"
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
}

resource "kubernetes_storage_class_v1" "nvme" {
  metadata {
    name = "nvme"
  }
  parameters = {
    type       = "gp3"
    iops       = "5000"
    throughput = "300"
  }

  volume_binding_mode = "WaitForFirstConsumer"
  storage_provisioner = "kubernetes.io/no-provisioner"
  reclaim_policy      = "Retain"
}
