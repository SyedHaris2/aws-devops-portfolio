variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "production"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# VPC Variables
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks (Frontend tier)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks (Backend tier)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "database_subnets" {
  description = "Database subnet CIDR blocks (DB tier)"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for all private subnets"
  type        = bool
  default     = true
}

# RDS Database Variables
variable "db_engine" {
  description = "RDS database engine"
  type        = string
  default     = "mysql"
  validation {
    condition     = contains(["postgres", "mysql", "mariadb"], var.db_engine)
    error_message = "Supported engines: postgres, mysql, mariadb"
  }
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Database allocated storage in GB"
  type        = number
  default     = 20
  validation {
    condition     = var.db_allocated_storage >= 20
    error_message = "Database storage must be at least 20 GB"
  }
}

variable "db_username" {
  description = "Master username for database"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Master password for database (use AWS Secrets Manager in production)"
  type        = string
  sensitive   = true
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = true
}

variable "db_backup_retention" {
  description = "Database backup retention in days"
  type        = number
  default     = 7
}

# ALB Variables
variable "enable_https" {
  description = "Enable HTTPS on ALB"
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = ""
}

# Backend Configuration
variable "backend_instance_count" {
  description = "Number of backend instances"
  type        = number
  default     = 2
}

variable "backend_instance_type" {
  description = "Instance type for backend servers"
  type        = string
  default     = "t3.micro"
}

variable "backend_port" {
  description = "Port on which backend application runs"
  type        = number
  default     = 3000
}

# Common Tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    CreatedBy = "Terraform"
    ManagedBy = "Infrastructure-as-Code"
  }
}
