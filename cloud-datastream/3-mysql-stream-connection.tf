
// 3. Create Datastream connection profile for MySQL (Cloud SQL)
resource "google_datastream_connection_profile" "mysql_cp" {
  connection_profile_id = "sakila-mysql"
  display_name          = "sakila-mysql"
  location              = "europe-west1"

mysql_profile {
    hostname = var.mysql_hostname
    port     = 3306
    username = var.mysql_username
    password = var.mysql_password
  }
}
