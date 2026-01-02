# Local values for common configurations
locals {
  common_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      CreatedDate = timestamp()
    }
  )

  # Database configuration
  db_config = {
    port     = 5432
    username = var.db_username
    password = var.db_password
    db_name  = "appdb"
  }

  # Network configuration
  network_config = {
    vpc_cidr           = var.vpc_cidr
    public_subnets     = var.public_subnets
    private_subnets   = var.private_subnets
    database_subnets  = var.database_subnets
  }
}
