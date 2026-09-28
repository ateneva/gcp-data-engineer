// Datastream: Sakila Cloud SQL -> BigQuery
// This file creates Datastream resources that replicate the sakila Cloud SQL database into BigQuery.

# create a BigQuery dataset for the Sakila database
resource "google_bigquery_dataset" "sakila_bq" {
  dataset_id  = "sakila"
  location    = var.region
  description = "This dataset stores streaming data from sakila mysql database"
}

# create a service accounts and IAM roles for Datastream
resource "google_service_account" "datastream_sa" {
  account_id   = "datastream-sa"
  display_name = "Datastream service account"
}

resource "google_project_iam_member" "datastream_bq_writer" {
  project = var.gcp_project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.datastream_sa.email}"
}

resource "google_project_iam_member" "datastream_admin" {
  project = var.gcp_project_id
  role    = "roles/datastream.admin"
  member  = "serviceAccount:${google_service_account.datastream_sa.email}"
}

// Datastream connection profile: MySQL (Cloud SQL)
resource "google_datastream_connection_profile" "mysql_cp" {
  connection_profile_id = "sakila-mysql-cp"
  display_name          = "sakila-mysql-cp"
  location              = var.region

  mysql_profile {
    hostname = google_sql_database_instance.mysql_instance.public_ip_address
    port     = 3306
    username = google_sql_user.db_user.name
    password = random_password.db_password.result
  }
}

// Datastream connection profile: BigQuery destination
resource "google_datastream_connection_profile" "bq_cp" {
  connection_profile_id = "sakila-bigquery-cp"
  display_name          = "sakila-bigquery-cp"
  location              = var.region
  bigquery_profile {}
}

resource "google_datastream_stream" "sakila_to_bq" {
  stream_id    = "sakila-to-bq-stream"
  display_name = "Sakila -> BigQuery"
  location     = var.region

  // Desired state required (RUNNING or PAUSED)
  desired_state = "RUNNING"

  source_config {
    source_connection_profile = google_datastream_connection_profile.mysql_cp.id

    mysql_source_config {
      include_objects {
        mysql_databases {
          database = "sakila"
        }
      }
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.bq_cp.id

    bigquery_destination_config {
      single_target_dataset {
        dataset_id = "${var.gcp_project_id}:${google_bigquery_dataset.sakila_bq.dataset_id}"
      }
    }
  }
  backfill_all {}
}
