# Create a dynamodb table for storing terraform state locks
resource "aws_dynamodb_table" "this" {
  for_each = toset([for t in toset(["terraform-state-lock"]) : t if local.cloud_provider == "aws"])

  name         = each.key
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    { "Name" = each.key },
    local.tags
  )
}

# Create an IAM user for running terraform and grant it IAMFullAccess and
# PowerUserAccess policies
resource "aws_iam_user" "this" {
  for_each = toset([for u in toset(["terraform-service-account"]) : u if local.cloud_provider == "aws"])

  name = each.key
  tags = local.tags
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each = {
    for p in toset(["IAMFullAccess", "PowerUserAccess"]) : "terraform-service-account|policy|${p}" => {
      policy_arn = "arn:aws:iam::aws:policy/${p}",
      user       = "terraform-service-account",
    } if local.cloud_provider == "aws"
  }

  policy_arn = each.value.policy_arn
  user       = aws_iam_user.this[each.value.user].name
}

# Create a KMS key and alias for encrypting terraform state
resource "aws_kms_key" "this" {
  for_each = toset([for k in toset(["terraform-state"]) : k if local.cloud_provider == "aws"])

  deletion_window_in_days = 14
  description             = "KMS Key used to encrypt terraform state S3 bucket"
  tags                    = local.tags
}

resource "aws_kms_alias" "this" {
  for_each = toset([for k in toset(["terraform-state"]) : k if local.cloud_provider == "aws"])

  target_key_id = aws_kms_key.this[each.key].key_id
  name          = "alias/${each.key}"
}

# Create an S3 bucket with versioning for our state
resource "aws_s3_bucket" "this" {
  for_each = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "aws"])

  bucket = "${random_id.this.hex}-${each.key}"
  tags = merge(
    { "Name" : "${random_id.this.hex}-${each.key}" },
    local.tags,
  )
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "aws"])

  bucket = aws_s3_bucket.this[each.key].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "aws"])

  bucket = aws_s3_bucket.this[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "this" {
  for_each = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "aws"])

  depends_on = [
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_public_access_block.this,
  ]

  bucket = aws_s3_bucket.this[each.key].id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  # This loop uses the KMS key identifier
  for_each = toset([for k in toset(["terraform-state"]) : k if local.cloud_provider == "aws"])

  bucket = aws_s3_bucket.this[each.key].id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this[each.key].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "aws"])

  depends_on = [
    aws_s3_bucket_acl.this,
    aws_s3_bucket_server_side_encryption_configuration.this,
  ]

  bucket = aws_s3_bucket.this[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}
