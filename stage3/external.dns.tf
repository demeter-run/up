resource "helm_release" "external_dns" {
  for_each   = toset([for n in toset(["v1"]) : n if var.enable_external_dns])
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.15.1"
  namespace  = "kube-system"

  values = [
    <<EOF
provider: cloudflare

# Log levels: panic,fatal,error,warning,info,debug,trace
logLevel: debug
logFormat: "json"

metrics:
  enabled: "true"

env:
  - name: CF_API_TOKEN
    value: ${var.cloudflare_token}

sources:
  - crd
  - service

# Use sync only if external-dns is the only service managing DNS records
policy: upsert-only
registry: txt
txtOwnerId: ${var.cluster_name}
txtPrefix: "_externaldns."

tolerations:
  - key: "demeter.run/availability-sla"
    operator: "Equal"
    value: "consistent"
    effect: "NoSchedule"

  - key: "demeter.run/compute-profile"
    operator: "Equal"
    value: "general-purpose"
    effect: "NoSchedule"

  - key: "demeter.run/compute-arch"
    operator: "Equal"
    value: "x86"
    effect: "NoSchedule"
EOF
  ]
}

resource "kubernetes_manifest" "ogmios_dns_endpoint" {
  for_each = toset([for n in toset(["v1"]) : n if var.enable_external_dns])
  manifest = {
    apiVersion = "externaldns.k8s.io/v1alpha1"
    kind       = "DNSEndpoint"
    metadata = {
      name      = "ogmios-cname"
      namespace = "kube-system"
    }
    spec = {
      endpoints = [
        {
          dnsName    = "ogmios.${var.ogmios_dns_zone}"
          recordType = "CNAME"
          targets    = var.ogmios_cname_targets
          providerSpecific = [
            {
              name  = "external-dns.alpha.kubernetes.io/cloudflare-proxied"
              value = "true"
            }
          ]
        }
      ]
    }
  }
}
