# Production-Ready AWS VPC Terraform Project

A complete, production-ready Terraform configuration for deploying a three-tier AWS infrastructure with Frontend (ALB), Backend (EC2), and Database (MySQL RDS) layers.

**✅ TESTED & WORKING**: This infrastructure has been successfully deployed and tested, serving "Backend: production" via ALB at port 80.

Important: this repository is prepared as a portfolio demo. It is safe to deploy for short-term demonstration, but DO NOT commit any real secrets (for example, `terraform.tfvars` containing `db_password`). After you finish a demo, run `terraform destroy` to remove all created resources and avoid unwanted costs.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        INTERNET                             │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTPS (80/443)
                           ▼
        ┌──────────────────────────────────────┐
        │  PUBLIC SUBNETS (Frontend Tier)      │
        │  ┌────────────────────────────────┐  │
        │  │   Application Load Balancer    │  │
        │  └────────┬───────────────────────┘  │
        │           │                           │
        │           │ HTTP (80)                 │
        └───────────┼───────────────────────────┘
                    │
        ┌───────────▼───────────────────────────┐
        │ PRIVATE SUBNETS (Backend/App Tier)   │
        │ ┌──────────┐  ┌──────────┐           │
        │ │ Backend  │  │ Backend  │ (Auto)    │
        │ │ EC2 #1   │  │ EC2 #2   │ (Scale)   │
        │ └────┬─────┘  └────┬─────┘           │
        │      │             │                  │
        │      │  MySQL      │                  │
        │      └──────┬──────┘                  │
        └─────────────┼────────────────────────┘
                      │
        ┌─────────────▼────────────────────────┐
        │ DATABASE SUBNETS (DB Tier)           │
        │ ┌──────────────────────────────────┐ │
        │ │   RDS MySQL                      │ │
        │ │   (Multi-AZ, Encrypted)          │ │
        │ └──────────────────────────────────┘ │
        │                                       │
        └───────────────────────────────────────┘
```

## Features

✅ **Three-Tier Architecture**
- **Frontend Tier**: Application Load Balancer in public subnets
- **Backend Tier**: EC2 instances in private subnets (Apache HTTPD on port 80)
- **Database Tier**: RDS MySQL in private database subnets

✅ **Security Best Practices**
- VPC with public, private, and database subnets
- Security groups with least-privilege access
- RDS encryption at rest (KMS)
- VPC Flow Logs for network monitoring
- No public database access
- IAM roles for EC2 instances

✅ **High Availability**
- Multi-AZ deployment
- NAT Gateway for private subnet internet access
- Load balancer health checks
- Database backup and recovery
- CloudWatch monitoring and alarms

✅ **Production-Ready Features**
- HTTPS/SSL support
- Enhanced RDS monitoring
- CloudWatch alarms
- Modular VPC module
- Comprehensive outputs

## Project Structure

```
.
├── provider.tf                 # AWS provider configuration
├── variables.tf                # Root-level variables
├── main.tf                     # Main infrastructure
├── output.tf                   # Output definitions
├── terraform.tfvars.example    # Example variables
├── README.md                   # This file
├── modules/
│   └── vpc/
│       ├── main.tf             # VPC resources
│       ├── variables.tf         # VPC variables
│       └── outputs.tf           # VPC outputs
└── user_data/
    └── backend.sh              # EC2 bootstrap script
```

## Quick Start

### 1. Setup

```bash
cd "AWS-VPC-Terraform-Project"
cp terraform.tfvars.example terraform.tfvars
```

### 2. Configure Variables

Edit `terraform.tfvars`:

```hcl
aws_region      = "us-east-1"
project_name    = "production"
db_username     = "admin"
db_password     = "YourSecurePassword123!"
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Demo / Showcase (Portfolio)

This project is intended as a portfolio piece. The following quick demo sequence will deploy the infrastructure, show outputs, and then destroy everything so you can safely demonstrate the project and push the repository to GitHub.

1. Copy the example variables and edit locally (do NOT commit this file):

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set db_password (for local testing only)
```

2. Initialize and create a plan (saved to `tfplan`):

```bash
terraform init
terraform plan -out=tfplan
```

3. Apply the saved plan non-interactively (no password prompt):

```bash
terraform apply "tfplan"
```

4. Verify outputs (ALB DNS, RDS endpoint, etc.):

```bash
terraform output -raw alb_dns_name
terraform output -raw rds_address
```

5. When done, destroy the demo infrastructure:

```bash
terraform destroy -auto-approve
```

Security note: prefer setting `TF_VAR_db_password` as an environment variable when demonstrating instead of writing secrets to disk:

```bash
export TF_VAR_db_password='TestOnlyPass123!'
terraform apply -auto-approve
unset TF_VAR_db_password
```

Push to GitHub after removing any sensitive local files. Use SSH or a PAT for authentication (SSH recommended).


## Key Outputs

```bash
# Get load balancer DNS
terraform output -raw alb_dns_name

# Get database endpoint
terraform output -raw rds_address

# Get backend instance IDs
terraform output backend_instance_ids

# Get full summary
terraform output infrastructure_summary
```

## Configuration Variables

### VPC
| Variable | Default | Description |
|----------|---------|-------------|
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `public_subnets` | `["10.0.1.0/24", "10.0.2.0/24"]` | Frontend subnets |
| `private_subnets` | `["10.0.10.0/24", "10.0.11.0/24"]` | Backend subnets |
| `database_subnets` | `["10.0.20.0/24", "10.0.21.0/24"]` | Database subnets |

### Backend
| Variable | Default | Description |
|----------|---------|-------------|
| `backend_instance_count` | `2` | Number of instances |
| `backend_instance_type` | `t3.micro` | Instance type |
| `backend_port` | `80` | App port (Apache HTTPD) |

### Database
| Variable | Default | Description |
|----------|---------|-------------|
| `db_engine` | `mysql` | Database engine |
| `db_instance_class` | `db.t3.micro` | Instance class |
| `db_allocated_storage` | `20` | Storage (GB) |
| `db_multi_az` | `true` | Multi-AZ enabled |

## Accessing Infrastructure

### Frontend (ALB)

```bash
ALB_DNS=$(terraform output -raw alb_dns_name)
curl http://$ALB_DNS/health
```

### Backend Instances

```bash
# Connect via Session Manager
INSTANCE_ID=$(terraform output -raw backend_instance_ids | jq -r '.[0]')
aws ssm start-session --target $INSTANCE_ID
```

### Database

```bash
RDS_HOST=$(terraform output -raw rds_address)
mysql -h $RDS_HOST -u admin -p appdb
```

## Scaling

### Scale Backend Instances

```hcl
# In terraform.tfvars
backend_instance_count = 4
```

```bash
terraform apply
```

### Scale Database

```hcl
# In terraform.tfvars
db_allocated_storage = 100
```

```bash
terraform apply
```

## Security Highlights

✅ **Network Isolation**
- Public ALB in public subnets
- Backend in private subnets
- Database in isolated subnets

✅ **Data Protection**
- RDS encryption (KMS)
- SSL/TLS support
- Automated backups

✅ **Access Control**
- Security group rules
- IAM roles
- VPC Flow Logs

## Monitoring

### CloudWatch Alarms (Automatic)
- RDS CPU > 80%
- RDS storage < 5GB
- ALB unhealthy hosts

### View Logs

```bash
# VPC Flow Logs
aws logs tail /aws/vpc/flowlogs/production --follow

# Database logs
aws logs tail /aws/rds/instance/production-db/mysql --follow
```

## Troubleshooting

### Terraform Init Issues

```bash
terraform init -upgrade
terraform validate
```

### ALB Health Check Failing

```bash
aws ssm start-session --target <instance-id>
pm2 logs
```

### Database Connection Failed

```bash
aws ec2 describe-security-group-rules \
  --filters Name=group-id,Values=<backend-sg-id>
```

## Cost Optimization

For development:

```hcl
backend_instance_count = 1
backend_instance_type  = "t3.micro"
db_instance_class      = "db.t3.micro"
single_nat_gateway     = true
db_multi_az            = false
```

## Important Notes

⚠️ **Before Production**:
1. Use strong database password
2. Use AWS Secrets Manager for passwords
3. Enable HTTPS with ACM certificate
4. Configure S3 backend for state
5. Review all security group rules
6. Set up SNS alarms

## Commands

```bash
# Initialize
terraform init

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Destroy
terraform destroy

# View outputs
terraform output
terraform output infrastructure_summary
```

## Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [RDS Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/)
- [ALB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)

## License

Open source - Use freely

---

**Created**: December 2024  
**Terraform Version**: >= 1.0  
**AWS Provider**: >= 5.0
