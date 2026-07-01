# 2. Creating Cluster EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "eks-commercial-study"
  cluster_version = "1.30" # Stable version of Kubernetes

  # Grants public access to the EKS API server (for GitHub Actions and other external tools)
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Worker nodes (Managed Node Groups) - bumped to t3.small to fit the
  # observability stack (Prometheus + Grafana) alongside the application
  eks_managed_node_groups = {
    k8s_nodes = {
      instance_types = ["t2.micro", "t3.micro", "t3.small"] # t2.micro is the free tier, but t3.micro/small are better for Prometheus/Grafana

      # Forcing static size
      min_size     = 2
      max_size     = 2
      desired_size = 2

      labels = {
        Environment = "k8s_nodes"
      }
    }
  }

  # Enabling IAM Role for Service Accounts (IRSA) to allow GitHub Actions to assume a role and interact with EKS
  enable_cluster_creator_admin_permissions = true
}