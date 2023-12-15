data "http" "cert_manager_crds_raw" {
  url = "https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.crds.yaml"
}

locals {
  crds = split("---", data.http.cert_manager_crds_raw.response_body)
}

resource "kubernetes_manifest" "cert_manager_crds" {
  for_each = { for x in local.crds: yamldecode(x).metadata.name => x }
  manifest = yamldecode(each.value)
}


