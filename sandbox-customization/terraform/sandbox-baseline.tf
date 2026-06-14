data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "account_group" {
  name = "/aft/account-request/custom-fields/group"
}

locals {
  bucket_name = "aft-sandbox-artifacts-sandy-${data.aws_caller_identity.current.account_id}"
}

# This control is intentionally scoped to accounts that select this customization.
resource "aws_s3_account_public_access_block" "sandbox" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "sandbox_artifacts" {
  bucket = local.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "sandbox-cost-control"
    enabled = true

    abort_incomplete_multipart_upload_days = 7

    noncurrent_version_expiration {
      days = 30
    }
  }

  tags = {
    Name        = "Sandbox artifacts"
    Environment = data.aws_ssm_parameter.account_group.value
    Purpose     = "Temporary development artifacts"
  }
}

resource "aws_s3_bucket_public_access_block" "sandbox_artifacts" {
  bucket = aws_s3_bucket.sandbox_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "sandbox_artifact_bucket_name" {
  description = "Artifact bucket created in the customized AFT account."
  value       = aws_s3_bucket.sandbox_artifacts.id
}
