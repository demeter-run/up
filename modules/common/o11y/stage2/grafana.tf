resource "kubernetes_config_map" "grafana_config" {
  metadata {
    name      = "grafana-config"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "grafana"
      "app.kubernetes.io/part-of"   = "demeter"
    }
  }
  data = {
    "grafana.ini" : <<EOT
    [date_formats]
    default_timezone = UTC
    EOT
  }
}

resource "kubernetes_stateful_set_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "grafana"
      "app.kubernetes.io/part-of"   = "demeter"
    }
  }

  spec {
    replicas = 1
    service_name = "grafana"
    selector {
      match_labels = {
        "app.kubernetes.io/component" = "o11y"
        "app.kubernetes.io/name"      = "grafana"
        "app.kubernetes.io/part-of"   = "demeter"
      }
    }
    volume_claim_template {
      metadata {
        name = "grafana-storage"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "5Gi"
          }
        }
        storage_class_name = "gp3"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "o11y"
          "app.kubernetes.io/name"      = "grafana"
          "app.kubernetes.io/part-of"   = "demeter"
        }
      }

      spec {

        volume {
          name = "tmp-plugins"

          empty_dir {
            medium = "Memory"
          }
        }

        volume {
          name = "grafana-config"

          config_map {
            name = "grafana-config"
          }
        }
        container {
          name  = "grafana"
          image = "grafana/grafana:9.2.6"

          port {
            name           = "http"
            container_port = 3000
          }

          resources {
            limits = {
              cpu    = "200m"
              memory = "400Mi"
            }

            requests = {
              cpu    = "100m"
              memory = "400Mi"
            }
          }

          volume_mount {
            name       = "grafana-storage"
            mount_path = "/var/lib/grafana"
          }

          volume_mount {
            name       = "tmp-plugins"
            mount_path = "/tmp"
          }

          volume_mount {
            name       = "grafana-config"
            mount_path = "/etc/grafana"
          }

          readiness_probe {
            http_get {
              path = "/api/health"
              port = "http"
            }
          }

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            read_only_root_filesystem = true
          }

        }

        security_context {
          run_as_user     = 65534
          run_as_non_root = true
          fs_group        = 65534
        }

        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-profile"
          operator = "Exists"
        }

        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-arch"
          operator = "Exists"
        }

        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/availability-sla"
          operator = "Equal"
          value    = "consistent"
        }

      }
    }
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = var.namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "grafana"
      "app.kubernetes.io/part-of"   = "demeter"
    }

    port {
      port     = 3000
      protocol = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = var.namespace
  }

  spec {
    ingress_class_name = var.ingress_class
    rule {
      host = "grafana.${var.cluster_name}.${var.dns_zone}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "grafana"
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
    rule {
      host = "grafana.${var.cluster_alias}.${var.dns_zone}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "grafana"
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}
