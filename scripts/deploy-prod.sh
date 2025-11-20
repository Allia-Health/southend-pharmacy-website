#!/bin/bash

# Deploy to Production Environment
set -e

echo "🚀 Deploying Southend Pharmacy to Production Environment"
echo "⚠️  WARNING: This will deploy to PRODUCTION!"
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

# Configuration
PROJECT_ID="southend-prod-pharmacy"
REGION="us-central1"
ENV_DIR="environments/prod"

# Navigate to project root
cd "$(dirname "$0")/.."

# Set the active project
echo "📦 Setting active GCP project..."
gcloud config set project ${PROJECT_ID}

# Build and push Docker image (if using custom image)
echo "🐳 Building Docker image..."
cd wordpress
docker build -t gcr.io/${PROJECT_ID}/wordpress:latest .
docker push gcr.io/${PROJECT_ID}/wordpress:latest
cd ..

# Deploy with Terraform
echo "🏗️  Deploying infrastructure with Terraform..."
cd ${ENV_DIR}

# Initialize Terraform
terraform init

# Plan
terraform plan -out=tfplan

echo ""
echo "⚠️  Please review the plan above carefully!"
read -p "Continue with apply? (yes/no): " apply_confirm

if [ "$apply_confirm" != "yes" ]; then
    echo "❌ Deployment cancelled"
    rm -f tfplan
    exit 1
fi

# Apply
terraform apply tfplan

# Get outputs
echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Outputs:"
terraform output

# Clean up plan file
rm -f tfplan

echo ""
echo "🌐 Cloud Run Service URL:"
terraform output cloud_run_service

echo ""
echo "🔐 To get the database password:"
echo "terraform output cloudsql_password"

