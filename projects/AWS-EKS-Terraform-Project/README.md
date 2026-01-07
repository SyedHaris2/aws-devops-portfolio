# 🚀 Node.js Microservices on AWS EKS with Terraform

A production-ready microservices e-commerce platform deployed on Amazon EKS, showcasing enterprise-grade cloud-native architecture and DevOps practices. This project demonstrates complete infrastructure as code, container orchestration, and scalable microservices design.

## 📋 Project Status

✅ **Infrastructure**: Complete Terraform configuration for AWS EKS, VPC, and ECR
✅ **Microservices**: 3 Node.js services (API Gateway, User Service, Product Service)
✅ **Kubernetes**: Complete manifests for deployment and scaling
✅ **CI/CD Ready**: GitHub Actions workflow configured
✅ **Documentation**: Comprehensive deployment and usage guides

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Internet      │────│  AWS ALB Ingress │────│  API Gateway    │
│                 │    │  (Load Balancer) │    │  (Port 3000)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                          │
                           ┌─────────────────┐           ┌─┴─────────────────┐
                           │   User Service  │◄──────────┤  JWT Auth         │
                           │   (Port 3001)   │           │  MongoDB          │
                           └─────────────────┘           └───────────────────┘
                                                          │
                           ┌─────────────────┐           └─┬─────────────────┘
                           │ Product Service │◄───────────┤  Product Catalog  │
                           │   (Port 3002)   │            └───────────────────┘
                           └─────────────────┘
```

### 🏢 Services Overview

| Service | Port | Description | Technology Stack |
|---------|------|-------------|------------------|
| **API Gateway** | 3000 | Centralized routing, load balancing, request aggregation | Node.js, Express, CORS |
| **User Service** | 3001 | User authentication, registration, JWT tokens | Node.js, Express, MongoDB, bcrypt |
| **Product Service** | 3002 | Product catalog management, CRUD operations | Node.js, Express, MongoDB, Multer |
| **MongoDB** | 27017 | Document database for all services | MongoDB, Kubernetes StatefulSet |

## Remote State Setup (Recommended)

For production use, set up remote state storage first:

1. **Create state resources:**
```bash
terraform apply -target=aws_s3_bucket.state_bucket -target=aws_dynamodb_table.state_lock
```

2. **Initialize with remote backend:**
```bash
terraform init
```

## Quick Start

### Phase 1: Deploy EKS Infrastructure
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Deploy EKS cluster
terraform apply
```

### Phase 2: Configure kubectl
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name microservices-cluster
```

### Phase 3: Deploy Microservices
```bash
# Navigate to Kubernetes manifests
cd k8s-manifests

# Deploy all services
./deploy.sh

# Or deploy manually
kubectl apply -f namespace.yaml
kubectl apply -f mongodb-deployment.yaml
kubectl apply -f user-service-deployment.yaml
kubectl apply -f product-service-deployment.yaml
kubectl apply -f api-gateway-deployment.yaml
```

### Phase 4: Test Application
```bash
# Get service URL
kubectl get svc api-gateway -n microservices

# Test health check
curl http://YOUR_LOAD_BALANCER_URL/health

# Test user registration
curl -X POST http://YOUR_LOAD_BALANCER_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'
```

### Phase 5: Cleanup
```bash
# Delete Kubernetes resources
kubectl delete namespace microservices

# Destroy EKS cluster
terraform destroy
```

## Configuration

Edit `terraform.tfvars` to customize:
- AWS region and availability zones
- EKS cluster name and node configuration
- VPC CIDR and subnet ranges
- Instance types and scaling parameters

## Key Components

- **VPC Module**: Reusable networking infrastructure
- **EKS Cluster**: Managed Kubernetes control plane
- **Node Groups**: Spot instances for cost-effective compute
- **ALB Ingress**: Load balancing and SSL termination
- **MongoDB**: Database deployment with persistent storage
- **Microservices**: Containerized Node.js applications
- **ConfigMaps/Secrets**: Environment configuration
- **Health Checks**: Kubernetes probes for reliability

## Cost Optimization

- **Spot Instances**: ~70% cheaper than on-demand
- **Single AZ**: Reduces cross-AZ costs
- **Minimal Resources**: Only what's needed for portfolio
- **Auto-scaling**: Scale to zero when not in use

## Monitoring & Debugging

```bash
# Check pod status
kubectl get pods -n microservices

# View logs
kubectl logs -f deployment/user-service -n microservices

# Port forward for local testing
kubectl port-forward svc/api-gateway 3000:80 -n microservices
```

## Portfolio Highlights

This project demonstrates:

1. **Infrastructure as Code**: Terraform for complete AWS infrastructure
2. **Container Orchestration**: Kubernetes deployments and services
3. **Microservices Architecture**: Independent, scalable services
4. **Cloud-Native**: AWS EKS with managed services
5. **Cost Optimization**: Spot instances and efficient resource usage
6. **DevOps Practices**: CI/CD ready with Docker and Kubernetes
7. **Security**: JWT auth, network policies, least privilege
8. **Monitoring**: Health checks, logging, debugging
9. **Scalability**: Horizontal pod autoscaling
10. **Production-Ready**: Load balancing, health checks, rollbacks

## 📋 Prerequisites

Before deploying, ensure you have:

- **AWS CLI** configured with appropriate permissions
- **Terraform** >= 1.0.0 installed
- **kubectl** installed and configured
- **Docker** for building container images
- **Git** for version control
- **Node.js** >= 18 for local development

### Required AWS Permissions:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:*",
        "ec2:*",
        "iam:*",
        "ecr:*",
        "s3:*",
        "dynamodb:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## 🛠️ Local Development

### Running Services Locally

```bash
# Start MongoDB
docker run -d -p 27017:27017 --name mongodb mongo:latest

# Install dependencies for each service
cd node-js-microservices/api-gateway && npm install
cd ../user-service && npm install
cd ../product-service && npm install

# Start services individually
cd node-js-microservices/user-service && npm run dev
cd ../product-service && npm run dev
cd ../api-gateway && npm run dev

# Or use Docker Compose (if configured)
docker-compose up -d
```

### Testing APIs Locally

```bash
# API Gateway health check
curl http://localhost:3000/health

# User registration
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'

# Product listing
curl http://localhost:3000/api/products
```

## 📸 Screenshots & Documentation

This project includes a comprehensive screenshot guide in the `screenshots/` directory. Key visual documentation includes:

- AWS EKS cluster deployment
- ECR repository management
- Kubernetes pod status and services
- API testing results
- Architecture diagrams

See `screenshots/README.md` for detailed screenshot guidelines.

## 🔍 Deployment Verification

After deployment, verify everything is working:

```bash
# Check cluster status
kubectl cluster-info

# Verify pods are running
kubectl get pods -n microservices

# Check services
kubectl get svc -n microservices

# View logs
kubectl logs -f deployment/api-gateway -n microservices

# Test external access
curl http://YOUR_ALB_URL/health
```

### Health Check Endpoints

- `GET /health` - Overall system health
- `GET /api/auth/health` - User service health
- `GET /api/products/health` - Product service health

## 📁 Project Structure

```
├── .github/
│   └── workflows/          # CI/CD pipelines
├── k8s-manifests/         # Kubernetes deployment files
│   ├── namespace.yaml
│   ├── mongodb-deployment.yaml
│   ├── *-service-deployment.yaml
│   └── secrets.yaml
├── modules/               # Reusable Terraform modules
│   └── vpc/              # VPC networking module
├── node-js-microservices/ # Application source code
│   ├── api-gateway/
│   ├── user-service/
│   └── product-service/
├── screenshots/          # Deployment documentation
├── .gitignore           # Git ignore rules
├── *.tf                 # Terraform configuration
├── deploy.sh           # Deployment automation script
└── README.md           # This file
```


## 📞 Support

For questions or issues:
- Check the troubleshooting section above
- Review Kubernetes logs: `kubectl logs -n microservices`
- Verify AWS resource status in the console

---

**🎉 Your complete microservices platform is ready for deployment!**

*This project showcases  DevOps and cloud architecture skills, perfect for portfolio demonstrations and technical interviews.*
