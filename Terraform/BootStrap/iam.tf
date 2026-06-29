# Creating role for CI/CD infrastructure using GitHub Actions
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-infra-role"

  # Trust Policy: Defines WHO can assume this role (GitHub OIDC)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Carneiro1908/ComercialKurbenetes:*"
          }
        }
      }
    ]
  })
}

# Inline Policy: Defines WHAT the GitHub Actions pipeline can actually do
resource "aws_iam_role_policy" "github_actions_permissions" {
  name = "github-actions-permissions-policy"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "VPCRoutingAndNetworkingPermissions"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "ec2:*Vpc*",
          "ec2:*Subnet*",
          "ec2:*Gateway*",
          "ec2:*Route*",
          "ec2:*Address*",
          "ec2:*SecurityGroup*"
        ]
      },
      {
        Sid      = "EC2InstancesAndTemplatesPermissions"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:Describe*",
          "ec2:CreateKeyPair",
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate"
        ]
      },
      {
        Sid      = "EKSMiscellaneousAndClusterPermissions"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "eks:CreateCluster",
          "eks:DeleteCluster",
          "eks:DescribeCluster",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:CreateNodegroup",
          "eks:DeleteNodegroup",
          "eks:DescribeNodegroup",
          "eks:UpdateNodegroupConfig",
          "eks:AccessKubernetesApi"
        ]
      },
      {
        Sid      = "IAMRolesRequiredForEKS"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:PassRole"
        ]
      },
      {
        Sid      = "S3BucketPermissions"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
      },
      {
        Sid      = "DynamoDBTerraformLockingPermissions"
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:*:*:table/comercial-k8s-terraform-locks"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
      }
    ]
  })
}

# ARN Output to use on the role 
output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_role.arn
  description = "ARN of the IAM role for GitHub Actions to assume"
}