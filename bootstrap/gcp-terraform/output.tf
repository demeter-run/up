output "terraform_project_id" {
  value = local.project_id
}

output "terraform_state_bucket" {
  value = google_storage_bucket.terraform_state.id
}

output "terraform_state_crypto_key" {
  value = google_kms_crypto_key.terraform_state_bucket.id
}

output "region" {
  value = local.region
}
