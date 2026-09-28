# 1. SQL Server Connection Profile (Source)
resource "google_datastream_connection_profile" "sql_server_source" {
  display_name          = "sql-server-adventureworks-source"
  location              = var.region
  connection_profile_id = "sql-server-source"

  sql_server_profile {
    hostname = google_sql_database_instance.sqlserver_instance.public_ip_address
    port     = 1433
    username = "sqlserver"
    password = random_password.sa_password.result
    database = "AdventureWorksDW2017"
  }
}

# 2. BigQuery Connection Profile (Destination)
resource "google_datastream_connection_profile" "adventureworks_bq" {
  display_name          = "bigquery-adventureworks"
  location              = var.region
  connection_profile_id = "bigquery-dest"

  bigquery_profile {}
}

# 3. Datastream Stream
resource "google_datastream_stream" "adventureworks_stream" {
  display_name              = "AdventureWorks CDC Stream"
  location                  = var.region
  stream_id                 = "adventureworks-cdc-stream"
  create_without_validation = true

  source_config {
    source_connection_profile = google_datastream_connection_profile.sql_server_source.id
    sql_server_source_config {

      # Include all tables in the AdventureWorksDW2017 database
      include_objects {
        schemas {
          schema = "dbo"
        }
      }
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.adventureworks_bq.id
    bigquery_destination_config {
      data_freshness = "900s" # 15 minutes
      single_target_dataset {
        dataset_id = "${var.gcp_project_id}:${google_bigquery_dataset.datastream_dataset.dataset_id}"
      }
    }
  }

  backfill_all {}

  # The stream must be started manually or through gcloud after CDC is enabled on the DB
  desired_state = "RUNNING"
}

# 4. BigQuery Dataset for the Destination
resource "google_bigquery_dataset" "datastream_dataset" {
  dataset_id                 = "adventureworks_cdc"
  location                   = var.region
  description                = "Dataset for Datastream CDC from SQL Server"
  delete_contents_on_destroy = true
}
