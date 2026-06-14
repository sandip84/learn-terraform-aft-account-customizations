data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "sandbox_bucket" {
  bucket = "aft-sandbox-shar-${data.aws_caller_identity.current.account_id}"
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "sandbox_bucket" {
  bucket = aws_s3_bucket.sandbox_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
