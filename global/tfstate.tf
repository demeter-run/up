resource "random_id" "this" {
  byte_length = 8
}

resource "cloudflare_r2_bucket" "terraform_state_bucket" {
  account_id = var.cloudflare_account_id
  name       = "${random_id.this.hex}-bucket-tfstate"
  location   = "ENAM"
}

output "terraform_state_bucket" {
  value = cloudflare_r2_bucket.terraform_state_bucket.name
}
