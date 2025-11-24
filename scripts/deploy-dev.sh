#!/bin/bash

# Deploy to Development Environment
set -e

echo "🚀 Deploying Southend Pharmacy to Development Environment"

# Configuration
PROJECT_ID="allia-sp-dev"
REGION="us-central1"
ENV_DIR="environments/dev"

# Navigate to project root
cd "$(dirname "$0")/.."

# Set the active project
echo "📦 Setting active GCP project..."
gcloud config set project ${PROJECT_ID}

# Build and push Docker image using Cloud Build
echo "🐳 Building Docker image with Cloud Build..."
gcloud builds submit wordpress \
  --tag us-central1-docker.pkg.dev/${PROJECT_ID}/wordpress/wordpress:latest \
  --project=${PROJECT_ID}

# Deploy with Terraform
echo "🏗️  Deploying infrastructure with Terraform..."
cd ${ENV_DIR}

# Initialize Terraform
terraform init

# Plan
terraform plan \
  -var="wordpress_image=us-central1-docker.pkg.dev/${PROJECT_ID}/wordpress/wordpress:latest" \
  -out=tfplan

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

