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

resource "kubernetes_service_v1" "kong_ping_endpoint" {
  metadata {
    name      = "kong-ping-endpoint"
    namespace = "dmtr-system"
  }
  spec {
    # This value will not be used for routing, but must resolve always.
    external_name = "kubernetes.default.svc"
    type          = "ExternalName"
  }
}

resource "kubernetes_manifest" "kong_ping_endpoint_request_termination_plugin" {
  manifest = {
    apiVersion = "configuration.konghq.com/v1"
    kind       = "KongPlugin"

    metadata = {
      name      = "kong-ping-endpoint-request-termination"
      namespace = "dmtr-system"
    }
    "plugin" = "request-termination"
    "config" = {
      "status_code" = 200
      "message"     = "PONG"
    }
  }
}

resource "kubernetes_ingress_v1" "kong_ping_endpoint" {
  metadata {
    name      = "kong-ping-endpoint"
    namespace = "dmtr-system"
    annotations = {
      "kubernetes.io/ingress.class" = "kong"
      "konghq.com/plugins"          = "kong-ping-endpoint-request-termination"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/ping_provider_healthcheck"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = "kong-ping-endpoint"
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
