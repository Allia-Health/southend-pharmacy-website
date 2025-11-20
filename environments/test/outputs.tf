/**
 * Outputs for Development Environment
 */

output "cloud_run_service" {
  description = "CloudRun service URL"
  value       = module.cloud_run.service.status[0].url
  sensitive   = true
}

output "cloudsql_password" {
  description = "CloudSQL password"
  value       = var.cloudsql_password == null ? random_password.cloudsql_password.result : var.cloudsql_password
  sensitive   = true
}

output "cloudsql_connection_name" {
  description = "CloudSQL connection name"
  value       = module.cloudsql.connection_name
}

output "cloudsql_ip" {
  description = "CloudSQL IP address"
  value       = module.cloudsql.ip
}

output "wordpress_uploads_bucket" {
  description = "Cloud Storage bucket for WordPress uploads"
  value       = google_storage_bucket.wordpress_uploads.name
}

output "project_id" {
  description = "The project ID"
  value       = module.project.project_id
}

