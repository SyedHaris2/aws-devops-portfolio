# Temporarily commented out to create resources first
# terraform {
#   backend "s3" {
#     bucket         = "microservices-eks-terraform-state-2025"
#     key            = "microservices/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "ecs-demo-terraform-locks"
#     encrypt        = true
#   }
# }
