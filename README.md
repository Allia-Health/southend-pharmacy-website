# Southend Pharmacy Website - WordPress on Google Cloud Run

Simple, elegant WordPress website for Southend Pharmacy Store hosted on Google Cloud Platform.

## Overview

This repository contains the infrastructure as code (IaC) for deploying the Southend Pharmacy website on Google Cloud Platform using Cloud Run, Cloud SQL, and Cloud Storage.

## Architecture

- **Cloud Run**: Serverless container platform for hosting WordPress
- **Cloud SQL**: Managed MySQL database (MySQL 8.4)
- **Cloud Storage**: Object storage for WordPress uploads and media
- **VPC Connector**: Secure connection between Cloud Run and Cloud SQL
- **Custom Theme**: Simple, modern theme displaying "Southend Pharmacy"

## Project Structure

```
southend-pharmacy-website/
├── environments/
│   ├── dev/          # Development environment
│   ├── test/         # Test environment
│   └── prod/         # Production environment
├── wordpress/        # WordPress custom theme and Dockerfile
│   ├── Dockerfile
│   └── southend-pharmacy-theme/
│       ├── style.css
│       ├── index.php
│       └── functions.php
├── scripts/          # Deployment scripts
└── README.md
```

## GCP Projects

- **Development**: `southend-dev-pharmacy`
- **Test**: `southend-test-pharmacy`
- **Production**: `southend-prod-pharmacy`

## Prerequisites

1. **Google Cloud SDK**: Install and configure gcloud CLI
2. **Terraform**: Version >= 1.4.4
3. **Docker**: For building custom WordPress image
4. **Access**: Owner role in the Allia Health GCP organization (ID: 1016215762249)

## Quick Start

### 1. Create GCP Projects

```bash
cd /Users/sbeuran/Documents/Work/Allia-Health/Repositories/southend-pharmacy-website
./scripts/setup-gcp-projects.sh
```

### 2. Link Billing Accounts

Via GCP Console:
- Dev: https://console.cloud.google.com/billing/linkedaccount?project=southend-dev-pharmacy
- Test: https://console.cloud.google.com/billing/linkedaccount?project=southend-test-pharmacy
- Prod: https://console.cloud.google.com/billing/linkedaccount?project=southend-prod-pharmacy

### 3. Deploy to Development

```bash
./scripts/deploy-dev.sh
```

This will:
- Build the custom WordPress Docker image with the Southend Pharmacy theme
- Push it to Google Container Registry
- Create Cloud SQL instance (MySQL 8.4)
- Set up VPC and networking
- Deploy Cloud Run service
- Create Cloud Storage bucket

**Expected time**: 15-20 minutes

## Website Design

The website features a clean, modern design with:
- **Gradient background**: Purple to blue gradient
- **Centered card layout**: White card with rounded corners
- **Pharmacy icon**: 💊 emoji as logo
- **"Southend Pharmacy" heading**: Large, gradient text
- **"Coming Soon" badge**: Prominent call-to-action
- **Contact information**: Email link for inquiries
- **Responsive design**: Works on all devices

## Custom Theme

The `southend-pharmacy-theme` includes:
- **style.css**: Modern CSS with gradients and animations
- **index.php**: Simple HTML structure
- **functions.php**: WordPress theme setup

## Deployment

### Development Environment

```bash
./scripts/deploy-dev.sh
```

### Test Environment

```bash
./scripts/deploy-test.sh
```

### Production Environment

```bash
./scripts/deploy-prod.sh
```

## Domain Configuration

After deployment, update DNS records to point to Cloud Run:

- **Dev**: `dev.southendpharmacystore.com`
- **Test**: `test.southendpharmacystore.com`
- **Prod**: `southendpharmacystore.com`

## Accessing Outputs

```bash
# Get Cloud Run URL
cd environments/dev
terraform output cloud_run_service

# Get database password
terraform output cloudsql_password

# Get all outputs
terraform output
```

## Monitoring

```bash
# View Cloud Run logs
gcloud run services logs read sp-dev-cr-wordpress \
  --project=southend-dev-pharmacy \
  --region=us-central1

# View Cloud SQL logs
gcloud sql operations list \
  --instance=sp-dev-mysql \
  --project=southend-dev-pharmacy
```

## Cost Estimates

### Development
- Cloud Run: ~$5-10/month
- Cloud SQL (db-g1-small): ~$25-30/month
- Cloud Storage: ~$1-5/month
- VPC Connector: ~$8/month
- **Total**: ~$40-55/month

### Test
- Same as Development: ~$40-55/month

### Production
- Cloud Run: ~$10-20/month
- Cloud SQL (db-n1-standard-1): ~$50-60/month
- Cloud Storage: ~$5-10/month
- VPC Connector: ~$8/month
- **Total**: ~$75-100/month

**Grand Total (All Environments)**: ~$155-210/month

## Security

- Database passwords: Auto-generated and stored in Terraform state
- Cloud Run access: Set to `allUsers` (public website)
- Cloud SQL: Uses private IP with VPC connector
- Deletion protection: Enabled for production

## Cleanup

To destroy an environment:

```bash
cd environments/dev  # or test/prod
terraform destroy
```

## Support

For issues or questions, contact the Allia Health DevOps team.

## License

Copyright © 2024 Allia Health. All rights reserved.

