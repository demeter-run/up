output "terraform_state_bucket" {
  value = join(",", values(aws_s3_bucket.this)[*].id)
}

output "region" {
  value = local.region
}
