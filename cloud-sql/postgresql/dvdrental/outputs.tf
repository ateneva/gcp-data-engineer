output "instance_name" {
  value       = google_sql_database_instance.postgres_dvdrental_instance.name
  description = "The name of the Cloud SQL instance"
}

output "db_name" {
  value       = google_sql_database.dvdrental_db.name
  description = "The name of the database"
}

output "db_user" {
  value       = google_sql_user.dvdrental_db_user.name
  description = "The database user"
}

output "db_password" {
  value     = random_password.dvdrental_db_password.result
  sensitive = true
}

output "connection_name" {
  value       = google_sql_database_instance.postgres_dvdrental_instance.connection_name
  description = "The connection name of the instance"
}

output "gcp_project_id" {
  value       = var.gcp_project_id
  description = "The GCP project ID"
}
