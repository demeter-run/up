variable "namespace" {
  type    = string
  default = "kube-system"
}

variable "configmap_name" {
  type    = string
  default = "nvme-provisioner-config"
}

variable "service_account_name" {
  type    = string
  default = "nvme-provisioner"
}

variable "cluster_role_name" {
  type    = string
  default = "nvme-provisioner-node-role"
}

variable "cluster_role_binding_name" {
  type    = string
  default = "nvme-provisioner-node-binding"
}

resource "kubernetes_config_map_v1" "config" {
  metadata {
    name      = var.configmap_name
    namespace = var.namespace
  }

  data = {
    nodeLabelsForPV = "- kubernetes.io/hostname"
    storageClassMap = file("${path.module}/storage_class_map.yml")
  }
}


resource "kubernetes_service_account_v1" "service_account" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
  }
}


resource "kubernetes_cluster_role_v1" "cluster_role" {
  metadata {
    name = var.cluster_role_name
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["watch"]
  }

  rule {
    api_groups = ["", "events.k8s.io"]
    resources  = ["events"]
    verbs      = ["create", "update", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get"]
  }
}


resource "kubernetes_cluster_role_binding_v1" "cluster_role_binding" {
  metadata {
    name = var.cluster_role_binding_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = var.cluster_role_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.service_account_name
    namespace = var.namespace
  }
}


resource "kubernetes_daemon_set_v1" "daemonset" {
  metadata {
    namespace = var.namespace
    name      = "nvme-provisioner"
    labels = {
      "app.kubernetes.io/name" : "nvme-provisioner"
    }
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" : "nvme-provisioner"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" : "nvme-provisioner"
        }
      }

      spec {

        container {
          image             = "registry.k8s.io/sig-storage/local-volume-provisioner:v2.6.0"
          image_pull_policy = "Always"
          name              = "provisioner"

          env {
            name = "MY_NODE_NAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "spec.nodeName"
              }
            }
          }

          env {
            name = "MY_NAMESPACE"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.namespace"
              }
            }
          }

          port {
            container_port = 8080
            name           = "metrics"
            protocol       = "TCP"
          }

          security_context {
            privileged = true
          }

          resources {}

          termination_message_path   = "/dev/termination-log"
          termination_message_policy = "File"

          volume_mount {
            mount_path = "/etc/provisioner/config"
            name       = "provisioner-config"
            read_only  = true
          }

          volume_mount {
            mount_path        = "/mnt/provisioned"
            mount_propagation = "HostToContainer"
            name              = "disks"
          }
        }

        dns_policy     = "ClusterFirst"
        restart_policy = "Always"
        scheduler_name = "default-scheduler"

        service_account_name             = var.service_account_name
        termination_grace_period_seconds = 30

        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-profile"
          operator = "Equal"
          value    = "disk-intensive"
        }

        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/availability-sla"
          value    = "consistent"
          operator = "Equal"
        }

        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-arch"
          operator = "Exists"
        }

        volume {
          name = "provisioner-config"
          config_map {
            default_mode = "0420"
            name         = var.configmap_name
          }
        }

        volume {
          name = "disks"
          host_path {
            path = "/mnt/provisioned"
            type = ""
          }
        }
      }
    }
  }
}
