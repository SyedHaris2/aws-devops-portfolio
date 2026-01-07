# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

# EKS Cluster Outputs
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.microservices_cluster.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = aws_eks_cluster.microservices_cluster.endpoint
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.microservices_cluster.arn
}

# EKS Compute Info (Fargate)
output "eks_compute_info" {
  description = "Compute information for EKS cluster"
  value       = "Using AWS Fargate for serverless pod execution in microservices namespace"
}

# kubectl Configuration
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.microservices_cluster.name}"
}

# Kubernetes Namespace
output "kubernetes_namespace" {
  description = "Kubernetes namespace for microservices"
  value       = "microservices"
}

# Infrastructure Summary
output "infrastructure_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    vpc_id             = module.vpc.vpc_id
    eks_cluster_name   = aws_eks_cluster.microservices_cluster.name
    eks_cluster_endpoint = aws_eks_cluster.microservices_cluster.endpoint
    compute_type       = "AWS Fargate (serverless)"
    kubernetes_namespace = "microservices"
    region             = var.aws_region
    project_name       = var.project_name
    environment        = var.environment
  }
}

# Deployment Instructions
output "next_steps" {
  description = "Next steps after Terraform deployment"
  value = [
    "1. Configure kubectl: aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.microservices_cluster.name}",
    "2. Build and push Docker images to ECR",
    "3. Deploy microservices: kubectl apply -f k8s-manifests/",
    "4. Check deployment: kubectl get pods -n microservices",
    "5. Get service URL: kubectl get svc api-gateway -n microservices"
  ]
}
