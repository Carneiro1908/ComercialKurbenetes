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

  # Work nodes (Managed Node Groups) - As freetier, we will use a single node group with 2 nodes
  eks_managed_node_groups = {
    k8s_nodes = {
      instance_types = ["t3.micro"] 

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