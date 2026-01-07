#!/bin/bash

# Complete EKS Microservices Deployment Script
# This script handles infrastructure + microservices deployment

set -e  # Exit on any error

echo "🚀 Complete Node.js Microservices EKS Deployment"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check prerequisites
print_step "Checking prerequisites..."
command -v terraform >/dev/null 2>&1 || { print_error "Terraform not found. Install it first."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { print_error "kubectl not found. Install it first."; exit 1; }
command -v aws >/dev/null 2>&1 || { print_error "AWS CLI not found. Install it first."; exit 1; }
command -v docker >/dev/null 2>&1 || { print_error "Docker not found. Install it first."; exit 1; }
print_status "All prerequisites installed!"

# Phase 1: Infrastructure Deployment
print_step "Phase 1: Deploying EKS Infrastructure..."
print_status "Initializing Terraform..."
terraform init

print_status "Planning infrastructure deployment..."
terraform plan -out=tfplan

print_status "Deploying EKS cluster (this takes ~15 minutes)..."
terraform apply tfplan

# Get cluster name and configure kubectl
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
print_status "Configuring kubectl for cluster: $CLUSTER_NAME"
aws eks update-kubeconfig --region us-east-1 --name $CLUSTER_NAME

# Phase 2: Create Node Group
print_step "Phase 2: Creating EKS Node Group..."
VPC_ID=$(terraform output -raw vpc_id)
SUBNETS=$(terraform output -raw private_subnets | tr -d '[],' | sed 's/"/ /g')

print_status "Creating node group with eksctl..."
eksctl create nodegroup \
  --cluster=$CLUSTER_NAME \
  --name=portfolio-nodes \
  --node-type=t3.small \
  --nodes=1 \
  --nodes-min=1 \
  --nodes-max=2 \
  --spot \
  --subnet-ids=$SUBNETS \
  --region=us-east-1

# Wait for nodes to be ready
print_status "Waiting for nodes to be ready..."
kubectl wait --for=condition=Ready node --all --timeout=300s

# Phase 3: Deploy Microservices
print_step "Phase 3: Deploying Microservices..."

# Create ECR repositories and build/push images
print_status "Creating ECR repositories..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

for repo in user-service product-service api-gateway; do
  aws ecr describe-repositories --repository-names $repo --region $REGION >/dev/null 2>&1 || \
  aws ecr create-repository --repository-name $repo --region $REGION
done

# Build and push images
print_status "Building and pushing Docker images..."

cd ../node-js-microservices/user-service
print_status "Building User Service..."
docker build -t $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/user-service:latest .
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/user-service:latest

cd ../product-service
print_status "Building Product Service..."
docker build -t $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/product-service:latest .
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/product-service:latest

cd ../api-gateway
print_status "Building API Gateway..."
docker build -t $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/api-gateway:latest .
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/api-gateway:latest

cd ../../k8s-manifests

# Update deployment YAMLs with ECR URLs
print_status "Updating deployment configurations..."
sed -i "s|your-registry|$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com|g" *.yaml

print_status "Docker images built and pushed!"

# Deploy to Kubernetes
print_status "Deploying to Kubernetes..."

# Create namespace
print_status "Creating namespace..."
kubectl apply -f namespace.yaml

# Create secrets (BEFORE deploying apps)
print_status "Creating secrets..."
kubectl apply -f mongodb-secret.yaml

# Deploy MongoDB
print_status "Deploying MongoDB..."
kubectl apply -f mongodb-deployment.yaml

# Wait for MongoDB to be ready
print_status "Waiting for MongoDB to be ready..."
kubectl wait --for=condition=ready pod -l app=mongodb -n microservices --timeout=300s

# Deploy services
print_status "Deploying User Service..."
kubectl apply -f user-service-deployment.yaml

print_status "Deploying Product Service..."
kubectl apply -f product-service-deployment.yaml

print_status "Deploying API Gateway..."
kubectl apply -f api-gateway-deployment.yaml

# Wait for all deployments to be ready
print_status "Waiting for all services to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/user-service -n microservices
kubectl wait --for=condition=available --timeout=300s deployment/product-service -n microservices
kubectl wait --for=condition=available --timeout=300s deployment/api-gateway -n microservices

# Get service URLs
print_status "Getting service information..."
API_GATEWAY_URL=$(kubectl get svc api-gateway -n microservices -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

print_status "🎉 Deployment completed successfully!"
echo ""
echo "Service URLs:"
echo "API Gateway: http://$API_GATEWAY_URL"
echo ""
echo "Health Checks:"
echo "API Gateway: http://$API_GATEWAY_URL/health"
echo "User Service: http://$API_GATEWAY_URL/api/auth/health"
echo "Product Service: http://$API_GATEWAY_URL/api/products/health"
echo ""
echo "Test Commands:"
echo "# Register user:"
echo "curl -X POST http://$API_GATEWAY_URL/api/auth/register \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"name\":\"Test User\",\"email\":\"test@example.com\",\"password\":\"password123\"}'"
echo ""
echo "# Get products:"
echo "curl http://$API_GATEWAY_URL/api/products"
echo ""
print_warning "Use 'kubectl get pods -n microservices' to check pod status"
print_warning "Use 'kubectl logs -f deployment/user-service -n microservices' to view logs"
