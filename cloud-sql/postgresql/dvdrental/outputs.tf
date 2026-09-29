# Cloud SQL Outputs
output "instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres_dvdrental_instance.name
}

output "instance_connection_name" {
  description = "Connection name used by Cloud SQL Proxy"
  value       = google_sql_database_instance.postgres_dvdrental_instance.connection_name
}

output "connection_name" {
  description = "The connection name of the instance"
  value       = google_sql_database_instance.postgres_dvdrental_instance.connection_name
}

output "public_ip_address" {
  description = "The public IPv4 address assigned to the Cloud SQL instance"
  value       = google_sql_database_instance.postgres_dvdrental_instance.public_ip_address
}

output "instance_service_account_email" {
  description = "The service account email address assigned to the Cloud SQL instance"
  value       = google_sql_database_instance.postgres_dvdrental_instance.service_account_email_address
}

output "db_name" {
  description = "The name of the database"
  value       = google_sql_database.dvdrental_db.name
}

output "db_user" {
  description = "The database user"
  value       = google_sql_user.dvdrental_db_user.name
}

output "db_username" {
  description = "The database username"
  value       = google_sql_user.dvdrental_db_user.name
}

output "db_password" {
  description = "The database password"
  value       = random_password.dvdrental_db_password.result
  sensitive   = true
}

output "gcp_project_id" {
  description = "The GCP project ID"
  value       = var.gcp_project_id
}

# PostgreSQL CDC / Replication Outputs
output "datastream_db_user" {
  description = "The Datastream CDC database user"
  value       = google_sql_user.datastream_user.name
}

output "datastream_db_password" {
  description = "The Datastream CDC database password"
  value       = random_password.datastream_db_password.result
  sensitive   = true
}

# Datastream Resources Outputs
output "datastream_bigquery_dataset_id" {
  description = "Dataset ID of the BigQuery destination for Datastream"
  value       = google_bigquery_dataset.dvdrental_bq.dataset_id
}

output "datastream_service_account_email" {
  description = "Email of the Datastream service account"
  value       = google_service_account.datastream_sa.email
}

output "datastream_postgres_connection_profile_id" {
  description = "Resource ID of the Datastream PostgreSQL source connection profile"
  value       = google_datastream_connection_profile.postgres_cp.id
}

output "datastream_bigquery_connection_profile_id" {
  description = "Resource ID of the Datastream BigQuery destination connection profile"
  value       = google_datastream_connection_profile.bq_cp.id
}

output "datastream_stream_id" {
  description = "Resource ID of the Datastream stream"
  value       = google_datastream_stream.dvdrental_to_bq.id
}

output "datastream_stream_name" {
  description = "Stream identifier of the Datastream stream"
  value       = google_datastream_stream.dvdrental_to_bq.stream_id
}

output "datastream_stream_state" {
  description = "Desired state of the Datastream stream"
  value       = google_datastream_stream.dvdrental_to_bq.desired_state
}
