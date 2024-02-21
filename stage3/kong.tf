resource "helm_release" "kong" {
  name       = "kong"
  namespace  = "dmtr-system"
  repository = "https://charts.konghq.com"
  chart      = "kong"
  version    = "2.37.0"

  values = [
    <<-EOT
    tolerations:
      - key: "demeter.run/compute-arch"
        operator: "Equal"
        value: "arm64"
        effect: "NoSchedule"
      - key: "demeter.run/compute-arch"
        operator: "Equal"
        value: "x86"
        effect: "NoSchedule"
      - key: "demeter.run/compute-profile"
        operator: "Equal"
        value: "admin"
        effect: "NoSchedule"
      - key: "demeter.run/availability-sla"
        operator: "Equal"
        value: "consistent"
        effect: "NoSchedule"
    EOT
  ]

  set {
    name  = "env.database"
    value = "off"
  }

  set {
    name  = "ingressController.enabled"
    value = "true"
  }

  set {
    name  = "proxy.type"
    value = "ClusterIP"
  }
}


# TODO this is a placeholder
resource "kubernetes_service_v1" "placeholder_service" {
  metadata {
    name      = "placeholder-service"
    namespace = "dmtr-system"
  }
  spec {
    selector = {
      app = "placeholder-app"
    }
    port {
      port        = 80
      target_port = 8080
    }
  }
}

# TODO this is a placeholder
resource "kubernetes_pod_v1" "placeholder_pod" {
  metadata {
    name      = "placeholder-pod"
    namespace = "dmtr-system"
    labels = {
      app = "placeholder-app"
    }
  }
  spec {
    container {
      image = "nginx"
      name  = "placeholder-container"

      port {
        container_port = 8080
      }
    }

    toleration {
      key      = "demeter.run/compute-arch"
      operator = "Equal"
      value    = "arm64"
      effect   = "NoSchedule"
    }

    toleration {
      key      = "demeter.run/compute-arch"
      operator = "Equal"
      value    = "x86"
      effect   = "NoSchedule"
    }

    toleration {
      key      = "demeter.run/compute-profile"
      operator = "Equal"
      value    = "admin"
      effect   = "NoSchedule"
    }

    toleration {
      key      = "demeter.run/availability-sla"
      operator = "Equal"
      value    = "consistent"
      effect   = "NoSchedule"
    }
  }
}

# TODO this is a placeholder
resource "kubernetes_ingress_v1" "dmtr_host_ingress" {
  metadata {
    name      = "dmtr-host-ingress"
    namespace = "dmtr-system"
    annotations = {
      "kubernetes.io/ingress.class" = "kong"
    }
  }

  spec {
    rule {
      host = "txpipe.dmtr.host"
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "placeholder-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    rule {
      host = "*.dmtr.host"
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "placeholder-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
