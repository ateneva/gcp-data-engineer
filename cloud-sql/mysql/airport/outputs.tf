output "instance_connection_name" {
  description = "Connection name used by Cloud SQL Proxy"
  value       = google_sql_database_instance.mysql_airport_instance.connection_name
}

output "public_ip_address" {
  description = "The public IPv4 address assigned to the Cloud SQL instance"
  value       = google_sql_database_instance.mysql_airport_instance.public_ip_address
}

output "airport_db_username" {
  value = google_sql_user.airport_db_user.name
}

output "airport_db_password" {
  value     = random_password.airport_db_password.result
  sensitive = true
}