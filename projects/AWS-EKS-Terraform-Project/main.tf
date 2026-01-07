# VPC Module - Foundation for EKS
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr       = var.vpc_cidr
  project_name   = var.project_name
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  azs           = var.azs
}

# EKS Cluster - Simplified and reliable
resource "aws_eks_cluster" "microservices_cluster" {
  name     = "${var.project_name}-eks-${random_string.suffix.result}"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.29"  # Currently supported version

  vpc_config {
    subnet_ids              = concat(module.vpc.public_subnets, module.vpc.private_subnets)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]

  tags = {
    Name        = "${var.project_name}-eks-cluster"
    Environment = var.environment
    Project     = "NodeJS-Microservices-Portfolio"
  }
}

# Random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-eks-cluster-role-${random_string.suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.project_name}-eks-cluster-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Fargate Profile for serverless compute
resource "aws_eks_fargate_profile" "microservices_fargate" {
  cluster_name           = aws_eks_cluster.microservices_cluster.name
  fargate_profile_name   = "microservices-profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn
  subnet_ids            = module.vpc.private_subnets

  selector {
    namespace = "microservices"
  }

  tags = {
    Name = "microservices-fargate-profile"
  }
}

# IAM Role for Fargate
resource "aws_iam_role" "eks_fargate_role" {
  name = "${var.project_name}-eks-fargate-role-${random_string.suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.project_name}-eks-fargate-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_fargate_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_role.name
}

# Additional ECR permissions for Fargate
resource "aws_iam_role_policy_attachment" "eks_fargate_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_fargate_role.name
}

# Output the cluster name for node group creation
output "eks_cluster_name_output" {
  description = "EKS cluster name for node group creation"
  value       = aws_eks_cluster.microservices_cluster.name
}
