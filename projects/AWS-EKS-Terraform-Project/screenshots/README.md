# Screenshots Directory

This directory contains screenshots demonstrating the microservices platform deployment and functionality.

## Recommended Screenshots to Add:

### 1. AWS Console Screenshots
- **EKS Cluster Overview** - Show the created EKS cluster in AWS console
- **ECR Repositories** - Display the private container repositories
- **Load Balancer** - Show the ALB configuration and DNS
- **VPC & Subnets** - Network architecture in AWS console

### 2. Kubernetes Dashboard Screenshots
- **Pod Status** - Running pods in microservices namespace
- **Service Endpoints** - Service discovery and load balancing
- **ConfigMaps & Secrets** - Configuration management
- **Resource Usage** - CPU/Memory utilization

### 3. Application Screenshots
- **API Gateway Response** - JSON response from the root endpoint
- **Health Check** - Health endpoint responses
- **User Registration** - Successful user creation with JWT
- **Product API** - Product listing and CRUD operations

### 4. Development Environment
- **Local Kubernetes** - kubectl get pods output
- **Docker Images** - Built container images
- **Terraform Plan** - Infrastructure planning output
- **Deployment Logs** - Successful deployment verification

### 5. Architecture Diagrams
- **System Architecture** - High-level component diagram
- **Data Flow** - Request/response flow through services
- **Network Topology** - VPC, subnets, and security groups

## How to Take Screenshots:

### AWS Console:
1. Navigate to EKS → Clusters → Your cluster
2. Go to ECR → Repositories
3. Check EC2 → Load Balancers
4. View VPC → Your VPC → Subnets

### Kubernetes:
```bash
# Get cluster info
kubectl cluster-info

# Pod status
kubectl get pods -n microservices -o wide

# Service endpoints
kubectl get svc -n microservices

# Resource usage
kubectl top pods -n microservices
```

### API Testing:
```bash
# API Gateway
curl http://your-alb-url.amazonaws.com/ | jq

# Health check
curl http://your-alb-url.amazonaws.com/health | jq

# User registration
curl -X POST http://your-alb-url.amazonaws.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Demo User","email":"demo@example.com","password":"password123"}' | jq

# Product listing
curl http://your-alb-url.amazonaws.com/api/products | jq
```

### Local Development:
```bash
# Docker images
docker images | grep microservices

# Local services
curl http://localhost:3000/ | jq
curl http://localhost:3001/health | jq
curl http://localhost:3002/health | jq
```

## File Naming Convention:

- `aws-eks-cluster.png` - EKS cluster in AWS console
- `aws-ecr-repositories.png` - Container repositories
- `aws-load-balancer.png` - ALB configuration
- `k8s-pods-status.png` - Kubernetes pod overview
- `k8s-services.png` - Service endpoints
- `api-gateway-response.png` - API Gateway JSON response
- `user-registration.png` - User registration API response
- `architecture-diagram.png` - System architecture diagram
- `terraform-plan.png` - Infrastructure deployment plan
- `local-development.png` - Local development setup

## Tools for Screenshots:

- **AWS Console** - Built-in screenshot functionality
- **Browser DevTools** - For API response screenshots
- **Terminal** - For kubectl output (use `script` command or screenshot)
- **Diagram Tools** - Draw.io, Lucidchart, or Excalidraw for architecture diagrams

## GitHub Repository Structure:

```
your-repo/
├── README.md                    # Main project README
├── screenshots/                 # Screenshots directory
│   ├── aws-eks-cluster.png
│   ├── aws-ecr-repositories.png
│   ├── k8s-pods-status.png
│   ├── api-gateway-response.png
│   └── architecture-diagram.png
├── terraform/                   # Infrastructure code
├── k8s-manifests/              # Kubernetes manifests
├── node-js-microservices/      # Application code
├── docs/                       # Additional documentation
└── .github/                    # GitHub templates
```

This will make your repository look professional and demonstrate the complete deployment process to potential employers or collaborators!
