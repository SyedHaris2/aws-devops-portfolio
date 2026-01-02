output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnets" {
  description = "Public subnet IDs (Frontend tier)"
  value       = aws_subnet.public[*].id
}

output "public_subnets_cidr" {
  description = "Public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnets" {
  description = "Private subnet IDs (Backend/App tier)"
  value       = aws_subnet.private[*].id
}

output "private_subnets_cidr" {
  description = "Private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

output "database_subnets" {
  description = "Database subnet IDs (DB tier)"
  value       = aws_subnet.database[*].id
}

output "database_subnets_cidr" {
  description = "Database subnet CIDR blocks"
  value       = aws_subnet.database[*].cidr_block
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_ips" {
  description = "NAT Gateway public IPs"
  value       = aws_eip.nat[*].public_ip
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}