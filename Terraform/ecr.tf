# Creating a secure and protected Amazon ECR Repository
resource "aws_ecr_repository" "protected_ecr" {
  name                 = "comercial-k8s-apps" # Name of your container repository
  image_tag_mutability = "MUTABLE"            # or IMMUTABLE if you want to prevent overwriting tags (e.g., 'latest')

  # 1. Continuous Vulnerability Scanning (Crucial for DevSecOps)
  image_scanning_configuration {
    scan_on_push = true
  }

  # 2. Encryption at rest using AWS KMS
  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = {
    Name        = "Protected Container Registry"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# 3. Lifecycle Policy: Keeps only the last 30 images to optimize storage costs
resource "aws_ecr_lifecycle_policy" "ecr_cleanup_policy" {
  repository = aws_ecr_repository.protected_ecr.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 30 images to save costs"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}