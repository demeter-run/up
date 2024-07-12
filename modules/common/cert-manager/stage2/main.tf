resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  create_namespace = true
  namespace        = "cert-manager"
  version          = "v1.12.0"

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "cert-manager"
  }

  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "tolerations[0].key"
    value = "demeter.run/compute-profile"
  }

  set {
    name  = "tolerations[1].effect"
    value = "NoSchedule"
  }

  set {
    name  = "tolerations[1].operator"
    value = "Exists"
  }

  set {
    name  = "tolerations[1].key"
    value = "demeter.run/compute-arch"
  }

  set {
    name  = "tolerations[2].effect"
    value = "NoSchedule"
  }

  set {
    name  = "tolerations[2].operator"
    value = "Equal"
  }

  set {
    name  = "tolerations[2].key"
    value = "demeter.run/availability-sla"
  }

  set {
    name  = "tolerations[2].value"
    value = "admin"
  }

  set {
    name  = "webhook.tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "webhook.tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "webhook.tolerations[0].key"
    value = "demeter.run/compute-profile"
  }

  set {
    name  = "webhook.tolerations[1].effect"
    value = "NoSchedule"
  }

  set {
    name  = "webhook.tolerations[1].operator"
    value = "Exists"
  }

  set {
    name  = "webhook.tolerations[1].key"
    value = "demeter.run/compute-arch"
  }

  set {
    name  = "webhook.tolerations[2].effect"
    value = "NoSchedule"
  }

  set {
    name  = "webhook.tolerations[2].operator"
    value = "Equal"
  }

  set {
    name  = "webhook.tolerations[2].key"
    value = "demeter.run/availability-sla"
  }

  set {
    name  = "webhook.tolerations[2].value"
    value = "admin"
  }

  set {
    name  = "cainjector.tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "cainjector.tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "cainjector.tolerations[0].key"
    value = "demeter.run/compute-profile"
  }

  set {
    name  = "cainjector.tolerations[1].effect"
    value = "NoSchedule"
  }

  set {
    name  = "cainjector.tolerations[1].operator"
    value = "Exists"
  }

  set {
    name  = "cainjector.tolerations[1].key"
    value = "demeter.run/compute-arch"
  }

  set {
    name  = "cainjector.tolerations[2].effect"
    value = "NoSchedule"
  }

  set {
    name  = "cainjector.tolerations[2].operator"
    value = "Equal"
  }

  set {
    name  = "cainjector.tolerations[2].key"
    value = "demeter.run/availability-sla"
  }

  set {
    name  = "cainjector.tolerations[2].value"
    value = "admin"
  }

  set {
    name  = "startupapicheck.tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "startupapicheck.tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "startupapicheck.tolerations[0].key"
    value = "demeter.run/compute-profile"
  }

  set {
    name  = "startupapicheck.tolerations[1].effect"
    value = "NoSchedule"
  }

  set {
    name  = "startupapicheck.tolerations[1].operator"
    value = "Exists"
  }

  set {
    name  = "startupapicheck.tolerations[1].key"
    value = "demeter.run/compute-arch"
  }

  set {
    name  = "startupapicheck.tolerations[2].effect"
    value = "NoSchedule"
  }

  set {
    name  = "startupapicheck.tolerations[2].operator"
    value = "Equal"
  }

  set {
    name  = "startupapicheck.tolerations[2].key"
    value = "demeter.run/availability-sla"
  }

  set {
    name  = "startupapicheck.tolerations[2].value"
    value = "admin"
  }

  set {
    name  = "webhook.serviceType"
    value = "LoadBalancer"
  }

  # set {
  #   name = "extraArgs[0]"
  #   value = "--feature-gates=ExperimentalGatewayAPISupport=true"
  # }
}

resource "kubernetes_manifest" "clusterissuer_letsencrypt" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt"
    }
    "spec" = {
      "acme" = {
        "email"          = var.acme_account_email
        "preferredChain" = ""
        "privateKeySecretRef" = {
          "name" = "issuer-account-key"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "podTemplate" = {
                  "spec" = {
                    "tolerations" = [
                      {
                        "effect"   = "NoSchedule"
                        "key"      = "demeter.run/compute-profile"
                        "operator" = "Exists"
                      },
                      {
                        "effect"   = "NoSchedule"
                        "key"      = "demeter.run/compute-arch"
                        "operator" = "Equal"
                        "value"    = "x86"
                      },
                      {
                        "effect"   = "NoSchedule"
                        "key"      = "demeter.run/availability-sla"
                        "operator" = "Exists"
                      }
                    ]
                  }
                }
              }
            }
            "selector" = {
              "dnsZones" = [
                "demeter.run",
                "demeter.builders",
              ]
            }
          },
          {
            "dns01" = {
              "route53" = {
                "region" = "eu-west-2"
                "secretAccessKeySecretRef" = {
                  "name" = ""
                }
              }
            }
          },
        ]
      }
    }
  }
}


resource "kubernetes_manifest" "clusterissuer_letsencrypt_http01" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-http01"
    }
    "spec" = {
      "acme" = {
        "email"          = var.acme_account_email
        "preferredChain" = ""
        "privateKeySecretRef" = {
          "name" = "issuer-account-key"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "podTemplate" = {
                  "spec" = {
                    "tolerations" = [
                      {
                        "effect"   = "NoSchedule"
                        "key"      = "demeter.run/compute-profile"
                        "operator" = "Exists"
                      },
                      {
                        "effect"   = "NoSchedule"
                        "key"      = "demeter.run/compute-arch"
                        "operator" = "Exists"
                      },
                      {
                        "effect"   = "NoSchedule"
                        "key"      = "demeter.run/availability-sla"
                        "operator" = "Exists"
                      }
                    ]
                  }
                }
              }
            }
          },
        ]
      }
    }
  }
}
