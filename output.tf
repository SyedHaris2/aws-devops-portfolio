# ====================================
# VPC OUTPUTS
# ====================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

# ====================================
# FRONTEND (PUBLIC SUBNETS) OUTPUTS
# ====================================

output "public_subnets" {
  description = "Public subnet IDs (Frontend tier)"
  value       = module.vpc.public_subnets
}

output "public_subnets_cidr" {
  description = "Public subnet CIDR blocks"
  value       = module.vpc.public_subnets_cidr
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.alb.dns_name
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.alb.arn
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.alb.zone_id
}

output "frontend_security_group_id" {
  description = "Frontend security group ID"
  value       = aws_security_group.alb_sg.id
}

# ====================================
# BACKEND (PRIVATE SUBNETS) OUTPUTS
# ====================================

output "private_subnets" {
  description = "Private subnet IDs (Backend tier)"
  value       = module.vpc.private_subnets
}

output "private_subnets_cidr" {
  description = "Private subnet CIDR blocks"
  value       = module.vpc.private_subnets_cidr
}

output "backend_instance_ids" {
  description = "Backend EC2 instance IDs"
  value       = aws_instance.backend[*].id
}

output "backend_instance_private_ips" {
  description = "Backend EC2 instance private IP addresses"
  value       = aws_instance.backend[*].private_ip
}

output "backend_security_group_id" {
  description = "Backend security group ID"
  value       = aws_security_group.backend_sg.id
}

output "backend_target_group_arn" {
  description = "Backend target group ARN"
  value       = aws_lb_target_group.tg.arn
}

# ====================================
# DATABASE (DB SUBNETS) OUTPUTS
# ====================================

output "database_subnets" {
  description = "Database subnet IDs (DB tier)"
  value       = module.vpc.database_subnets
}

output "database_subnets_cidr" {
  description = "Database subnet CIDR blocks"
  value       = module.vpc.database_subnets_cidr
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.postgres.endpoint
  sensitive   = true
}

output "rds_address" {
  description = "RDS database address"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "RDS database port"
  value       = aws_db_instance.postgres.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.postgres.db_name
}

output "rds_master_username" {
  description = "RDS master username"
  value       = aws_db_instance.postgres.username
  sensitive   = true
}

output "rds_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.postgres.identifier
}

output "database_security_group_id" {
  description = "Database security group ID"
  value       = aws_security_group.db_sg.id
}

# ====================================
# NAT GATEWAY OUTPUTS
# ====================================

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "nat_gateway_ips" {
  description = "NAT Gateway public IP addresses"
  value       = module.vpc.nat_gateway_ips
}

# ====================================
# INTERNET GATEWAY OUTPUTS
# ====================================

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

# ====================================
# CONNECTION STRINGS (for reference)
# ====================================

output "database_connection_string" {
  description = "MySQL connection string (for reference)"
  value       = "mysql://${aws_db_instance.postgres.username}:PASSWORD@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}"
  sensitive   = true
}

# ====================================
# COMPLETE INFRASTRUCTURE SUMMARY
# ====================================

output "infrastructure_summary" {
  description = "Complete infrastructure summary"
  value = {
    region     = var.aws_region
    project    = var.project_name
    environment = var.environment
    vpc = {
      id   = module.vpc.vpc_id
      cidr = module.vpc.vpc_cidr
    }
    frontend = {
      alb_dns     = aws_lb.alb.dns_name
      sg_id       = aws_security_group.alb_sg.id
      subnets     = module.vpc.public_subnets
    }
    backend = {
      instance_count = var.backend_instance_count
      instance_ids   = aws_instance.backend[*].id
      sg_id          = aws_security_group.backend_sg.id
      subnets        = module.vpc.private_subnets
    }
    database = {
      endpoint   = aws_db_instance.postgres.address
      port       = aws_db_instance.postgres.port
      engine     = var.db_engine
      sg_id      = aws_security_group.db_sg.id
      subnets    = module.vpc.database_subnets
    }
  }
}
