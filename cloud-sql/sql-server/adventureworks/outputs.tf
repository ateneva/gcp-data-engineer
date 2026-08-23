output "instance_connection_name" {
  description = "Connection name used by Cloud SQL Proxy"
  value       = google_sql_database_instance.sqlserver_instance.connection_name
}

output "public_ip_address" {
  description = "The public IPv4 address assigned to the Cloud SQL instance"
  value       = google_sql_database_instance.sqlserver_instance.public_ip_address
}

output "sa_username" {
  value = "sqlserver"
}

output "sa_password" {
  value     = google_sql_database_instance.sqlserver_instance.root_password
  sensitive = true
}

output "database_name" {
  value = "AdventureWorksDW2017"
}
