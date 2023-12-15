data "http" "gateway_crds_raw" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v0.7.1/experimental-install.yaml"
}

locals {
  crds_raw = split("---\n", file("${path.module}/crds.yaml"))
  # remove first element since it's not a CRD
  crds_tmp = slice(local.crds_raw, 1, length(local.crds_raw))
  # remove status field from each CRD
  crds_clean = { for x in local.crds_tmp : x => yamlencode(
    { for root_key, root_values in yamldecode(x) : root_key => root_values if root_key != "status" }
  ) }
}

resource "kubernetes_manifest" "gateway_crds" {
  for_each = { for x in local.crds_clean : "${yamldecode(x).metadata.name}-${yamldecode(x).kind}" => x }
  manifest = yamldecode(each.value)
}
