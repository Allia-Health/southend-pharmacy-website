#!/bin/bash

# Deploy to Development Environment
set -e

echo "🚀 Deploying Southend Pharmacy to Development Environment"

# Configuration
PROJECT_ID="southend-dev-pharmacy"
REGION="us-central1"
ENV_DIR="environments/dev"

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

