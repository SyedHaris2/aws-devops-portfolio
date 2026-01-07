# ECR Repositories for microservices
resource "aws_ecr_repository" "api_gateway" {
  name                 = "api-gateway"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name = "api-gateway"
  }
}

resource "aws_ecr_repository" "user_service" {
  name                 = "user-service"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name = "user-service"
  }
}

resource "aws_ecr_repository" "product_service" {
  name                 = "product-service"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name = "product-service"
  }
}

# Outputs
output "ecr_registry_url" {
  value       = "628087992272.dkr.ecr.us-east-1.amazonaws.com"
  description = "ECR registry URL"
}

output "api_gateway_repository_url" {
  value       = aws_ecr_repository.api_gateway.repository_url
  description = "API Gateway repository URL"
}

output "user_service_repository_url" {
  value       = aws_ecr_repository.user_service.repository_url
  description = "User Service repository URL"
}

output "product_service_repository_url" {
  value       = aws_ecr_repository.product_service.repository_url
  description = "Product Service repository URL"
}
