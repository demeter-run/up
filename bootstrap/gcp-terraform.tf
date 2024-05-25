locals {
  service_apis = [
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage.googleapis.com",
  ]
}

resource "google_service_account" "terraform_runner" {
  for_each                     = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "gcp"])
  account_id                   = "terraform-runner"
  display_name                 = "Terraform Runner"
  project                      = local.project_id
  create_ignore_already_exists = true
}

resource "google_project_service" "this" {
  for_each = toset([for t in toset(local.service_apis) : t if local.cloud_provider == "gcp"])
  project  = local.project_id
  service  = each.key

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_kms_key_ring" "terraform_state" {
  for_each = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "gcp"])
  name     = "${random_id.this.hex}-bucket-tfstate"
  location = "us"
  project  = local.project_id
}

resource "google_kms_crypto_key" "terraform_state_bucket" {
  for_each        = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "gcp"])
  name            = "${random_id.this.hex}-terraform-state-bucket"
  key_ring        = google_kms_key_ring.terraform_state[each.key].id
  rotation_period = "86400s"

  lifecycle {
    prevent_destroy = false
  }
}

data "google_storage_project_service_account" "this" {
  count = local.cloud_provider == "gcp" ? 1 : 0
}

resource "google_project_iam_member" "this" {
  for_each = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "gcp"])
  project  = local.project_id
  role     = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member   = "serviceAccount:${data.google_storage_project_service_account.this[0].email_address}"
}

resource "google_storage_bucket" "terraform_state" {
  for_each                    = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "gcp"])
  depends_on                  = [google_project_iam_member.this]
  name                        = "${random_id.this.hex}-bucket-tfstate"
  force_destroy               = false
  location                    = "US"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  encryption {
    default_kms_key_name = google_kms_crypto_key.terraform_state_bucket[each.key].id
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 2
      with_state         = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }

  versioning {
    enabled = true
  }
}
