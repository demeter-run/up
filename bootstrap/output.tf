output "region" {
  value = local.region
}

output "terraform_project_id" {
  value = local.project_id
}

output "terraform_state_crypto_key" {
  value = local.cloud_provider == "gcp" ? google_kms_crypto_key.terraform_state_bucket["terraform-state"].id : "Not applicable"
}

output "terraform_state_bucket" {
  value = local.cloud_provider == "aws" ? join(",", values(aws_s3_bucket.this)[*].id) : "Not applicable"
}
