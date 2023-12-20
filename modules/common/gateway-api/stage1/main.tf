data "external" "process_standard_yaml" {
  program = ["python3", abspath("${path.module}/parse_yaml.py"), "${path.module}/standard.yaml"]
}

data "external" "process_experimenta_yaml" {
  program = ["python3", abspath("${path.module}/parse_yaml.py"), "${path.module}/experimental.yaml"]
}

data "external" "process_kong_yaml" {
  program = ["python3", abspath("${path.module}/parse_yaml.py"), "${path.module}/kong.yaml"]
}

locals {
  crds = merge(
    data.external.process_standard_yaml.result,
    data.external.process_experimenta_yaml.result,
    data.external.process_kong_yaml.result,
  )

  # crds_old = data.external.process_old_yaml.result
}

resource "kubernetes_manifest" "gateway_crds" {
  for_each = local.crds

  manifest = yamldecode(each.value)
}
