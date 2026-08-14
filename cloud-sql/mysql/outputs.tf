output "instance_connection_name" {
  description = "Connection name used by Cloud SQL Proxy"
  value       = google_sql_database_instance.mysql_instance.connection_name
}

output "public_ip_address" {
  description = "The public IPv4 address assigned to the Cloud SQL instance"
  value       = google_sql_database_instance.mysql_instance.public_ip_address
}

output "db_username" {
  value = google_sql_user.db_user.name
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}