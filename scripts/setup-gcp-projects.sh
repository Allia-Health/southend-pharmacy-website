#!/bin/bash

# Setup GCP Projects for Southend Pharmacy
set -e

echo "🏗️  Setting up GCP Projects for Southend Pharmacy"

# Configuration
ORG_ID="1016215762249"
BILLING_ACCOUNT_ID=""

# Get billing account
echo "📋 Fetching billing accounts..."
gcloud billing accounts list

echo ""
read -p "Enter your billing account ID: " BILLING_ACCOUNT_ID

if [ -z "$BILLING_ACCOUNT_ID" ]; then
    echo "❌ Billing account ID is required"
    exit 1
fi

# Create projects
echo ""
echo "📦 Creating GCP projects..."

echo "Creating Development project..."
gcloud projects create allia-sp-dev \
    --organization=${ORG_ID} \
    --name="Southend Pharmacy Dev" || echo "Project already exists"

echo "Creating Staging project..."
gcloud projects create allia-sp-staging \
    --organization=${ORG_ID} \
    --name="Southend Pharmacy Staging" || echo "Project already exists"

echo "Creating Production project..."
gcloud projects create allia-sp-prod \
    --organization=${ORG_ID} \
    --name="Southend Pharmacy Prod" || echo "Project already exists"

# Link billing accounts
echo ""
echo "💳 Linking billing accounts..."

gcloud billing projects link allia-sp-dev \
    --billing-account=${BILLING_ACCOUNT_ID}

gcloud billing projects link allia-sp-staging \
    --billing-account=${BILLING_ACCOUNT_ID}

gcloud billing projects link allia-sp-prod \
    --billing-account=${BILLING_ACCOUNT_ID}

# Enable required APIs for all projects
echo ""
echo "🔌 Enabling required APIs..."

for project in allia-sp-dev allia-sp-staging allia-sp-prod; do
    echo "Enabling APIs for ${project}..."
    gcloud services enable \
        run.googleapis.com \
        logging.googleapis.com \
        monitoring.googleapis.com \
        sqladmin.googleapis.com \
        sql-component.googleapis.com \
        vpcaccess.googleapis.com \
        servicenetworking.googleapis.com \
        storage.googleapis.com \
        containerregistry.googleapis.com \
        cloudbuild.googleapis.com \
        --project=${project}
done

echo ""
echo "✅ GCP projects setup complete!"
echo ""
echo "Projects created:"
echo "  - allia-sp-dev"
echo "  - allia-sp-staging"
echo "  - allia-sp-prod"
echo ""
echo "Next steps:"
echo "  1. Review the terraform configurations in environments/"
echo "  2. Run ./scripts/deploy-dev.sh to deploy to development"

