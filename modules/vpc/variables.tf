variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets (Frontend tier)"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets (Backend/App tier)"
  type        = list(string)
}

variable "database_subnets" {
  description = "CIDR blocks for database subnets (DB tier)"
  type        = list(string)
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets (cost-effective)"
  type        = bool
  default     = true
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}