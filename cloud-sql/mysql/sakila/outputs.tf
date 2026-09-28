# Cloud SQL Outputs
output "instance_name" {
  description = "The name of the database instance"
  value       = google_sql_database_instance.mysql_instance.name
}

output "instance_connection_name" {
  description = "Connection name used by Cloud SQL Proxy"
  value       = google_sql_database_instance.mysql_instance.connection_name
}

output "public_ip_address" {
  description = "The public IPv4 address assigned to the Cloud SQL instance"
  value       = google_sql_database_instance.mysql_instance.public_ip_address
}

output "db_username" {
  description = "The database username"
  value       = google_sql_user.db_user.name
}

output "db_password" {
  description = "The database password"
  value       = random_password.db_password.result
  sensitive   = true
}

# Datastream Resources Outputs
output "datastream_staging_bucket_name" {
  description = "Name of the GCS staging bucket for Datastream"
  value       = google_storage_bucket.datastream_staging.name
}

output "datastream_staging_bucket_url" {
  description = "URL of the GCS staging bucket for Datastream"
  value       = google_storage_bucket.datastream_staging.url
}

output "datastream_bigquery_dataset_id" {
  description = "Dataset ID of the BigQuery destination for Datastream"
  value       = google_bigquery_dataset.sakila_bq.dataset_id
}

output "datastream_service_account_email" {
  description = "Email of the Datastream service account"
  value       = google_service_account.datastream_sa.email
}

output "datastream_mysql_connection_profile_id" {
  description = "Resource ID of the Datastream MySQL source connection profile"
  value       = google_datastream_connection_profile.mysql_cp.id
}

output "datastream_bigquery_connection_profile_id" {
  description = "Resource ID of the Datastream BigQuery destination connection profile"
  value       = google_datastream_connection_profile.bq_cp.id
}

output "datastream_stream_id" {
  description = "Resource ID of the Datastream stream"
  value       = google_datastream_stream.sakila_to_bq.id
}

output "datastream_stream_name" {
  description = "Stream identifier of the Datastream stream"
  value       = google_datastream_stream.sakila_to_bq.stream_id
}

output "datastream_stream_state" {
  description = "Desired state of the Datastream stream"
  value       = google_datastream_stream.sakila_to_bq.desired_state
}
