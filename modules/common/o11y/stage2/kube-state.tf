resource "kubernetes_deployment" "kube_state" {
  metadata {
    labels = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "kube-state-metrics"
      "app.kubernetes.io/part-of"   = "demeter"
    }
    name      = "kube-state-metrics"
    namespace = var.namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        "app.kubernetes.io/component" = "o11y"
        "app.kubernetes.io/name"      = "kube-state-metrics"
        "app.kubernetes.io/part-of"   = "demeter"
      }
    }

    template {
      metadata {
        annotations = {
          "kubectl.kubernetes.io/default-container" = "kube-state-metrics"
        }
        labels = {
          "app.kubernetes.io/component" = "o11y"
          "app.kubernetes.io/name"      = "kube-state-metrics"
          "app.kubernetes.io/part-of"   = "demeter"
        }
      }

      spec {
        automount_service_account_token = true

        container {
          args = [
            "--host=127.0.0.1",
            "--port=8081",
            "--telemetry-host=127.0.0.1",
            "--telemetry-port=8082",
          ]
          image = "registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.7.0"
          name  = "kube-state-metrics"
          resources {
            limits = {
              cpu    = "100m"
              memory = "250Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "190Mi"
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
            run_as_user               = 65534
          }
        }

        container {
          args = [
            "--logtostderr",
            "--secure-listen-address=:8443",
            "--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305",
            "--upstream=http://127.0.0.1:8081/",
          ]

          image = "quay.io/brancz/kube-rbac-proxy:v0.13.1"
          name  = "kube-rbac-proxy-main"

          port {
            container_port = 8443
            name           = "https-main"
          }

          resources {
            limits = {
              cpu    = "40m"
              memory = "40Mi"
            }
            requests = {
              cpu    = "20m"
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

        container {
          args = [
            "--logtostderr",
            "--secure-listen-address=:9443",
            "--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305",
            "--upstream=http://127.0.0.1:8082/",
          ]
          image = "quay.io/brancz/kube-rbac-proxy:v0.13.1"
          name  = "kube-rbac-proxy-self"
          port {
            container_port = 9443
            name           = "https-self"
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

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "kube-state-metrics"

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

resource "kubernetes_service_account" "kube_state" {
  metadata {
    labels = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "kube-state-metrics"
      "app.kubernetes.io/part-of"   = "demeter"
    }
    name      = "kube-state-metrics"
    namespace = var.namespace
  }
  automount_service_account_token = false
}


resource "kubernetes_cluster_role" "kube_state" {
  metadata {
    labels = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "kube-state-metrics"
      "app.kubernetes.io/part-of"   = "demeter"
    }
    name = "demeter:kube-state-metrics"
  }

  rule {
    api_groups = [
      "",
    ]
    resources = [
      "configmaps",
      "secrets",
      "nodes",
      "pods",
      "services",
      "serviceaccounts",
      "resourcequotas",
      "replicationcontrollers",
      "limitranges",
      "persistentvolumeclaims",
      "persistentvolumes",
      "namespaces",
      "endpoints",
    ]
    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "apps",
    ]
    resources = [
      "statefulsets",
      "daemonsets",
      "deployments",
      "replicasets",
    ]
    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "batch",
    ]
    resources = [
      "cronjobs",
      "jobs",
    ]
    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "autoscaling",
    ]
    resources = [
      "horizontalpodautoscalers",
    ]
    verbs = [
      "list",
      "watch",
    ]
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

  rule {
    api_groups = [
      "policy",
    ]
    resources = [
      "poddisruptionbudgets",
    ]
    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "certificates.k8s.io",
    ]
    resources = [
      "certificatesigningrequests",
    ]
    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "storage.k8s.io",
    ]
    resources = [
      "storageclasses",
      "volumeattachments",
    ]
    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "admissionregistration.k8s.io",
    ]
    resources = [
      "mutatingwebhookconfigurations",
      "validatingwebhookconfigurations",
    ]
    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "networking.k8s.io",
    ]
    resources = [
      "networkpolicies",
      "ingressclasses",
      "ingresses",
    ]
    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "coordination.k8s.io",
    ]
    resources = [
      "leases",
    ]
    verbs = [
      "list",
      "watch",
    ]
  }

  rule {
    api_groups = [
      "rbac.authorization.k8s.io",
    ]
    resources = [
      "clusterrolebindings",
      "clusterroles",
      "rolebindings",
      "roles",
    ]
    verbs = [
      "list",
      "watch",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "kube_state" {
  metadata {
    labels = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "kube-state-metrics"
      "app.kubernetes.io/part-of"   = "demeter"
    }
    name = "demeter:kube-state-metrics"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "demeter:kube-state-metrics"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "kube-state-metrics"
    namespace = var.namespace
  }
}

resource "kubernetes_service" "kube_state" {
  metadata {
    labels = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "kube-state-metrics"
      "app.kubernetes.io/part-of"   = "demeter"
    }
    name      = "kube-state-metrics"
    namespace = var.namespace
  }

  spec {
    cluster_ip = "None"

    port {
      name        = "https-main"
      port        = 8443
      target_port = "https-main"
    }

    port {
      name        = "https-self"
      port        = 9443
      target_port = "https-self"
    }

    selector = {
      "app.kubernetes.io/component" = "o11y"
      "app.kubernetes.io/name"      = "kube-state-metrics"
      "app.kubernetes.io/part-of"   = "demeter"
    }
  }
}

resource "kubernetes_manifest" "kube_state_pod_monitor" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "ServiceMonitor"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "o11y"
        "app.kubernetes.io/name"      = "kube-state-metrics"
        "app.kubernetes.io/part-of"   = "demeter"
      }
      "name"      = "kube-state-metrics"
      "namespace" = var.namespace
    }
    "spec" = {
      "endpoints" = [
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "honorLabels"     = true
          "interval"        = "30s"
          "metricRelabelings" = [
            {
              "action" = "drop"
              "regex"  = "kube_endpoint_address_not_ready|kube_endpoint_address_available"
              "sourceLabels" = [
                "__name__",
              ]
            },
          ]
          "port" = "https-main"
          "relabelings" = [
            {
              "action" = "labeldrop"
              "regex"  = "(pod|service|endpoint|namespace)"
            },
          ]
          "scheme"        = "https"
          "scrapeTimeout" = "30s"
          "tlsConfig" = {
            "insecureSkipVerify" = true
          }
        },
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "interval"        = "30s"
          "port"            = "https-self"
          "scheme"          = "https"
          "tlsConfig" = {
            "insecureSkipVerify" = true
          }
        },
      ]
      "jobLabel" = "app.kubernetes.io/name"
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "o11y"
          "app.kubernetes.io/name"      = "kube-state-metrics"
          "app.kubernetes.io/part-of"   = "demeter"
        }
      }
    }
  }
}
