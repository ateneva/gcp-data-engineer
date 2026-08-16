# Local variable to collect all local SQL files you want to track/import
locals {
  # List the exact filenames stored in your bucket path
  sql_files = toset([
    "airportdb@employee.sql",
    "airportdb@airline.sql",
    "airportdb@airplane.sql",
    "airportdb@airplane_type.sql",
    "airportdb@airport_geo.sql",
    "airportdb@airport_reachable.sql",
    "airportdb@airport.sql",
    "airportdb@booking.sql",
    "airportdb@flight_log.sql",
    "airportdb@flight.sql",
    "airportdb@flightschedule.sql",
    "airportdb@passenger.sql",
    "airportdb@passengerdetails.sql",
    "airportdb@weatherdata.sql"
  ])
}

# 1. Fetch Cloud Storage objects dynamically for each SQL file
data "google_storage_bucket_object" "sql_dumps" {
  for_each = local.sql_files

  name   = "gcp/databases/airport-db/${each.value}"
  bucket = "data-engineer-in-training"
}

# 2. Grant the Cloud SQL service account access to read from the bucket
resource "google_storage_bucket_iam_member" "import_airport_grant" {
  bucket = "data-engineer-in-training"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_sql_database_instance.mysql_airport_instance.service_account_email_address}"
}

# 3. Execute the import command for each SQL file
resource "null_resource" "airport_db_import" {
  triggers = {
    instance_id = google_sql_database_instance.mysql_airport_instance.id
    file_hashes = join(",", [for f in data.google_storage_bucket_object.sql_dumps : f.md5hash])
  }

  provisioner "local-exec" {
    command = <<EOT
      %{for file in local.sql_files~}
        echo "Importing ${file}..."
        gcloud sql import sql ${google_sql_database_instance.mysql_airport_instance.name} \
          gs://${data.google_storage_bucket_object.sql_dumps[file].bucket}/${data.google_storage_bucket_object.sql_dumps[file].name} \
          --database=${google_sql_database.airport_db.name} \
          --project=${var.gcp_project_id} \
          --no-async \
          --quiet
      %{endfor~}
    EOT
  }

  depends_on = [
    google_sql_database_instance.mysql_airport_instance,
    google_sql_database.airport_db,
    google_storage_bucket_iam_member.import_airport_grant,
    data.google_storage_bucket_object.sql_dumps
  ]
}