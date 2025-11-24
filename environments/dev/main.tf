/**
 * Southend Pharmacy - Development Environment
 * WordPress on Cloud Run with Cloud SQL
 */

terraform {
  required_version = ">= 1.4.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.69.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.69.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

locals {
  all_principals_iam = [for k in var.principals : "user:${k}"]
  cloudsql_conf = {
    database_version = "MYSQL_8_4"
    tier             = "db-g1-small"
    db               = "wp-mysql"
    user             = "admin"
  }
  iam = {
    # CloudSQL
    "roles/cloudsql.admin"        = local.all_principals_iam
    "roles/cloudsql.client"       = local.all_principals_iam
    "roles/cloudsql.instanceUser" = local.all_principals_iam
    # common roles
    "roles/logging.admin"                  = local.all_principals_iam
    "roles/iam.serviceAccountUser"         = local.all_principals_iam
    "roles/iam.serviceAccountTokenCreator" = local.all_principals_iam
  }
  connector = var.connector == null ? google_vpc_access_connector.connector.0.self_link : var.connector
  prefix    = var.prefix == null ? "" : "${var.prefix}-"
}

# Set up the project
module "project" {
  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v34.1.0"
  name            = var.project_id
  parent          = try(var.project_create.parent, null)
  billing_account = try(var.project_create.billing_account_id, null)
  project_create  = var.project_create != null
  prefix          = var.project_create == null ? null : var.prefix
  iam             = var.project_create != null ? local.iam : {}
  services = [
    "run.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "sqladmin.googleapis.com",
    "sql-component.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "storage.googleapis.com"
  ]
}

# Generate random passwords
resource "random_password" "cloudsql_password" {
  length  = 16
  special = true
}

# Create a VPC for CloudSQL
module "vpc" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-vpc?ref=v34.1.0"
  project_id = module.project.project_id
  name       = "${local.prefix}sql-vpc"
  subnets = [
    {
      ip_cidr_range = var.ip_ranges.sql_vpc
      name          = "subnet"
      region        = var.region
    }
  ]
  psa_configs = [{
    ranges = {
      cloud-sql = var.ip_ranges.psa
    }
  }]
}

# Create a VPC connector for the CloudSQL VPC
resource "google_vpc_access_connector" "connector" {
  count         = var.create_connector ? 1 : 0
  project       = module.project.project_id
  name          = "${local.prefix}wp-connector"
  region        = var.region
  ip_cidr_range = var.ip_ranges.connector
  network       = module.vpc.self_link
}

# Set up CloudSQL
module "cloudsql" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/cloudsql-instance?ref=v34.1.0"
  project_id = module.project.project_id
  network_config = {
    connectivity = {
      psa_config = {
        private_network = module.vpc.self_link
      }
    }
  }
  name                    = "${local.prefix}mysql"
  region                  = var.region
  database_version        = local.cloudsql_conf.database_version
  tier                    = local.cloudsql_conf.tier
  databases               = [local.cloudsql_conf.db]
  gcp_deletion_protection = false
  users                   = {}
}

# Create CloudSQL user manually to avoid sensitive value in for_each
resource "google_sql_user" "wordpress_user" {
  project  = module.project.project_id
  name     = local.cloudsql_conf.user
  instance = module.cloudsql.name
  password = random_password.cloudsql_password.result
}

# Create Cloud Storage bucket for WordPress uploads
resource "google_storage_bucket" "wordpress_uploads" {
  project       = module.project.project_id
  name          = "${var.project_id}-wordpress-uploads"
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

# Create the Cloud Run service
module "cloud_run" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/cloud-run?ref=v34.1.0"
  project_id = module.project.project_id
  name       = "${local.prefix}cr-wordpress"
  region     = var.region

  containers = {
    wordpress = {
      image = var.wordpress_image
      ports = {
        http = {
          container_port = var.wordpress_port
          name           = "http1"
          protocol       = null
        }
      }
      # Set up the database connection
      env = {
        "WORDPRESS_DB_HOST"     = module.cloudsql.ip
        "WORDPRESS_DB_NAME"     = local.cloudsql_conf.db
        "WORDPRESS_DB_USER"     = local.cloudsql_conf.user
        "WORDPRESS_DB_PASSWORD" = random_password.cloudsql_password.result
        # SMTP Configuration for email delivery
        "SMTP_HOST"             = var.smtp_host
        "SMTP_PORT"             = tostring(var.smtp_port)
        "SMTP_USER"             = var.smtp_user
        "SMTP_PASSWORD"         = var.smtp_password
        "SMTP_FROM"             = var.smtp_from
        "SMTP_FROM_NAME"        = var.smtp_from_name
        "SMTP_SECURE"            = var.smtp_secure
      }
    }
  }

  iam = {
    "roles/run.invoker" : [var.cloud_run_invoker]
  }

  revision_annotations = {
    autoscaling = {
      min_scale = 1
      max_scale = 3
    }
    # Connect to CloudSQL
    cloudsql_instances  = [module.cloudsql.connection_name]
    vpcaccess_connector = local.connector
    # Route only private traffic through VPC, allow internet access for WordPress.org
    vpcaccess_egress = "private-ranges-only"
  }
  ingress_settings = "all"
}

