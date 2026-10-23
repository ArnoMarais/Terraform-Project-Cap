# One bucket per environment: state for dev can never live in the prod bucket.
# To create buckets for the other environments, 
# uncomment the line in locals.tf that disables the other environments
# and comment the dev only line.
resource "aws_s3_bucket" "state" {
  for_each = local.environments

  bucket = "${var.prefix}-s3-${each.key}"

  # State is the record of what Terraform manages. Losing it orphans every
  # resource, so Terraform refuses to destroy these buckets.
  lifecycle {
    prevent_destroy = true
  }
}

# Versioning lets us recover an earlier state file after a bad apply.
resource "aws_s3_bucket_versioning" "state" {
  for_each = aws_s3_bucket.state

  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  for_each = aws_s3_bucket.state

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# As these buckets store sensitive state information, we block all public access to them.
resource "aws_s3_bucket_public_access_block" "state" {
  for_each = aws_s3_bucket.state

  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}