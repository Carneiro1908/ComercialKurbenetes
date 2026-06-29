# Creating a secure and protected S3 Bucket
resource "aws_s3_bucket" "protected_bucket" {
  bucket = "comercial-k8s-protected-storage-2026" # Replace with a globally unique name

  tags = {
    Name        = "Protected Infrastructure Storage"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# 1. Block all public access (Crucial for commercial security)
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.protected_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. Enable versioning (Protection against accidental deletes and ransomware)
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.protected_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Enable Server-Side Encryption using AWS KMS (Data at rest encryption)
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.protected_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true # Reduces KMS API costs significantly
  }
}

# 4. Lifecycle configuration (Cleans up old versions after 90 days to save costs)
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.protected_bucket.id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 60
    }
  }
}