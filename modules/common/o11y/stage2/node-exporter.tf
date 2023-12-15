resource "kubernetes_cluster_role" "node_exporter" {
  metadata {
    labels = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "node-exporter"
      "app.kubernetes.io/part-of"   = "demeter"
    }
    name = "demeter:node-exporter"
  }

  rule {
    api_groups = [
      "authentication.k8s.io",
    ]
    resources = [
      "tokenreviews",
    ]
    verbs = [
      "create",
    ]
  }

  rule {
    api_groups = [
      "authorization.k8s.io",
    ]
    resources = [
      "subjectaccessreviews",
    ]
    verbs = [
      "create",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "node_exporter" {
  metadata {
    labels = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "node-exporter"
      "app.kubernetes.io/part-of"   = "demeter"
    }
    name = "node-exporter"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "demeter:node-exporter"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "node-exporter"
    namespace = var.namespace
  }
}

resource "kubernetes_service_account" "node_exporter" {
  metadata {
    labels = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "node-exporter"
      "app.kubernetes.io/part-of"   = "demeter"
    }
    name      = "node-exporter"
    namespace = var.namespace
  }

  automount_service_account_token = false
}

resource "kubernetes_daemonset" "node_exporter" {
  metadata {
    labels = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "node-exporter"
      "app.kubernetes.io/part-of"   = "demeter"
    }
    name      = "node-exporter"
    namespace = var.namespace
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/component" = "o11y"
        "app.kubernetes.io/name"      = "node-exporter"
        "app.kubernetes.io/part-of"   = "demeter"
      }
    }

    template {
      metadata {
        annotations = {
          "kubectl.kubernetes.io/default-container" = "node-exporter"
        }
        labels = {
          "app.kubernetes.io/component" = "o11y"
          "app.kubernetes.io/name"      = "node-exporter"
          "app.kubernetes.io/part-of"   = "demeter"
        }
      }

      spec {
        automount_service_account_token = true

        container {
          args = [
            "--web.listen-address=127.0.0.1:9100",
            "--path.sysfs=/host/sys",
            "--path.rootfs=/host/root",
            "--path.udev.data=/host/root/run/udev/data",
            "--no-collector.wifi",
            "--no-collector.hwmon",
            "--collector.filesystem.mount-points-exclude=^/(dev|proc|sys|run/k3s/containerd/.+|var/lib/docker/.+|var/lib/kubelet/pods/.+)($|/)",
            "--collector.netclass.ignored-devices=^(veth.*|[a-f0-9]{15})$",
            "--collector.netdev.device-exclude=^(veth.*|[a-f0-9]{15})$",
          ]
          image = "quay.io/prometheus/node-exporter:v1.4.0"
          name  = "node-exporter"

          resources {
            limits = {
              cpu    = "250m"
              memory = "180Mi"
            }
            requests = {
              cpu    = "102m"
              memory = "180Mi"
            }
          }

          security_context {
            allow_privilege_escalation = false
            capabilities {
              add = [
                "SYS_TIME",
              ]
              drop = [
                "ALL",
              ]
            }
            read_only_root_filesystem = true
          }

          volume_mount {
            mount_path        = "/host/sys"
            mount_propagation = "HostToContainer"
            name              = "sys"
            read_only         = true
          }
          volume_mount {
            mount_path        = "/host/root"
            mount_propagation = "HostToContainer"
            name              = "root"
            read_only         = true
          }

        }
        container {
          args = [
            "--logtostderr",
            "--secure-listen-address=[$(IP)]:9100",
            "--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305",
            "--upstream=http://127.0.0.1:9100/",
          ]

          env {
            name = "IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          image = "quay.io/brancz/kube-rbac-proxy:v0.13.1"
          name  = "kube-rbac-proxy"
          port {
            container_port = 9100
            host_port      = 9100
            name           = "https"
          }

          resources {
            limits = {
              cpu    = "20m"
              memory = "40Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "20Mi"
            }
          }
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = [
                "ALL",
              ]
            }
            read_only_root_filesystem = true
            run_as_group              = 65532
            run_as_non_root           = true
            run_as_user               = 65532
          }
        }

        host_network = true
        host_pid     = true
        node_selector = {
          "kubernetes.io/os" = "linux"
        }
        priority_class_name = "system-cluster-critical"
        security_context {
          run_as_non_root = true
          run_as_user     = 65534
        }

        service_account_name = "node-exporter"

        toleration {
          operator = "Exists"
          effect   = "NoSchedule"
        }

        volume {
          host_path {
            path = "/sys"
          }
          name = "sys"
        }

        volume {
          host_path {
            path = "/"
          }
          name = "root"
        }
      }
    }
    strategy {
      rolling_update {
        max_unavailable = "10%"
      }
      type = "RollingUpdate"
    }
  }
}

resource "kubernetes_service" "node_exporter" {
  metadata {
    labels = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "node-exporter"
      "app.kubernetes.io/part-of"   = "demeter"
    }
    name      = "node-exporter"
    namespace = var.namespace
  }
  spec {
    cluster_ip = "None"

    port {
      name        = "https"
      port        = 9100
      target_port = "https"
    }

    selector = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "node-exporter"
      "app.kubernetes.io/part-of"   = "demeter"
    }
  }
}

resource "kubernetes_manifest" "servicemonitor_node_exporter" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "ServiceMonitor"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "o11y"
        "app.kubernetes.io/name"      = "node-exporter"
        "app.kubernetes.io/part-of"   = "demeter"
      }
      "name"      = "node-exporter"
      "namespace" = var.namespace
    }
    "spec" = {
      "endpoints" = [
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "interval"        = "15s"
          "port"            = "https"
          "relabelings" = [
            {
              "action"      = "replace"
              "regex"       = "(.*)"
              "replacement" = "$1"
              "sourceLabels" = [
                "__meta_kubernetes_pod_node_name",
              ]
              "targetLabel" = "instance"
            },
          ]
          "scheme" = "https"
          "tlsConfig" = {
            "insecureSkipVerify" = true
          }
        },
      ]
      "jobLabel" = "app.kubernetes.io/name"
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "o11y"
          "app.kubernetes.io/name"      = "node-exporter"
          "app.kubernetes.io/part-of"   = "demeter"
        }
      }
    }
  }
}
