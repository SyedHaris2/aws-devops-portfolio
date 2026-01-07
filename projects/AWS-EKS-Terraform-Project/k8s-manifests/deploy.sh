#!/bin/bash

# Node.js Microservices EKS Deployment Script
# This script deploys the complete microservices stack to EKS

set -e  # Exit on any error

echo "🚀 Starting Node.js Microservices EKS Deployment"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check prerequisites
print_status "Checking prerequisites..."

if ! command -v kubectl &> /dev/null; then
    print_error "kubectl not found. Please install kubectl first."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    print_error "docker not found. Please install Docker first."
    exit 1
fi

if ! command -v aws &> /dev/null; then
    print_error "aws CLI not found. Please install AWS CLI first."
    exit 1
fi

print_status "Prerequisites check passed!"

# Build and push Docker images
print_status "Building and pushing Docker images..."

# Build User Service
cd ../node-js-microservices/user-service
print_status "Building User Service..."
docker build -t your-registry/user-service:latest .
docker push your-registry/user-service:latest

# Build Product Service
cd ../product-service
print_status "Building Product Service..."
docker build -t your-registry/product-service:latest .
docker push your-registry/product-service:latest

# Build API Gateway
cd ../api-gateway
print_status "Building API Gateway..."
docker build -t your-registry/api-gateway:latest .
docker push your-registry/api-gateway:latest

cd ../../k8s-manifests

print_status "Docker images built and pushed!"

# Deploy to Kubernetes
print_status "Deploying to Kubernetes..."

# Create namespace
print_status "Creating namespace..."
kubectl apply -f namespace.yaml

# Deploy MongoDB
print_status "Deploying MongoDB..."
kubectl apply -f mongodb-deployment.yaml

# Wait for MongoDB to be ready
print_status "Waiting for MongoDB to be ready..."
kubectl wait --for=condition=ready pod -l app=mongodb -n microservices --timeout=300s

# Deploy User Service
print_status "Deploying User Service..."
kubectl apply -f user-service-deployment.yaml

# Deploy Product Service
print_status "Deploying Product Service..."
kubectl apply -f product-service-deployment.yaml

# Deploy API Gateway
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
print_warning "Remember to update image registry URLs in the deployment files!"
print_warning "Use 'kubectl get pods -n microservices' to check pod status"
print_warning "Use 'kubectl logs -f deployment/user-service -n microservices' to view logs"
