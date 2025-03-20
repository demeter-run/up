data "http" "cert_manager_crds" {
  url = "https://github.com/cert-manager/cert-manager/releases/download/v1.17.1/cert-manager.crds.yaml"
}

resource "null_resource" "apply_cert_manager_crds" {
  triggers = {
    crds_content = md5(data.http.cert_manager_crds.response_body)
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.1/cert-manager.crds.yaml"
  }
}
