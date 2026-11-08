// 3. Datastream connection profile: PostgreSQL (Cloud SQL)
resource "google_datastream_connection_profile" "postgres_cp" {
  connection_profile_id = "dvdrental-postgres"
  display_name          = "dvdrental-postgres"
  location              = "europe-west1"

  postgresql_profile {
    hostname = var.postgresql_hostname
    port     = 5432
    username = var.postgresql_username
    password = var.postgresql_password
    database = var.postgresql_db
  }
}