# Creating DynamoDB table for Terraform State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "comercial-k8s-terraform-locks"
  billing_mode = "PAY_PER_REQUEST" # On-demand billing (Very cheap and perfectly fits Free Tier)
  hash_key     = "LockID"

  # The attribute name MUST be exactly "LockID" (case-sensitive) for Terraform backend
  attribute {
    name = "LockID"
    type = "S" # String type
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}