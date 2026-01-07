# Bootstrap configuration for Terraform remote state
# This file creates the S3 bucket and DynamoDB table needed for remote state
# Run: terraform apply -target=aws_s3_bucket.state_bucket -target=aws_dynamodb_table.state_lock

# Temporarily commented out S3 bucket creation to focus on EKS
# resource "aws_s3_bucket" "state_bucket" {
#   bucket = var.state_bucket_name

#   tags = {
#     Name        = "${var.project_name}-terraform-state"
#     Environment = var.environment
#     Purpose     = "Terraform State Storage"
#   }
# }

# resource "aws_s3_bucket_versioning" "state_bucket" {
#   bucket = aws_s3_bucket.state_bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket" {
#   bucket = aws_s3_bucket.state_bucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#     bucket_key_enabled = true
#   }
# }

# resource "aws_s3_bucket_public_access_block" "state_bucket" {
#   bucket = aws_s3_bucket.state_bucket.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

resource "aws_dynamodb_table" "state_lock" {
  name           = var.state_lock_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-terraform-locks"
    Environment = var.environment
    Purpose     = "Terraform State Locking"
  }
}
