// Datastream: dvdrental PostgreSQL -> BigQuery

// 1. BigQuery Dataset for the dvdrental database
resource "google_bigquery_dataset" "dvdrental_bq" {
  dataset_id  = "dvdrental"
  location    = var.region
  description = "This dataset stores streaming data from dvdrental postgresql database"
}

// 2. Service Account and IAM roles for Datastream
resource "google_service_account" "datastream_sa" {
  account_id   = "datastream-sa-dvdrental"
  display_name = "Datastream service account for dvdrental"
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

// 3. Datastream connection profile: PostgreSQL (Cloud SQL)
resource "google_datastream_connection_profile" "postgres_cp" {
  connection_profile_id = "dvdrental-postgres-cp"
  display_name          = "dvdrental-postgres-cp"
  location              = var.region

  postgresql_profile {
    hostname = google_sql_database_instance.postgres_dvdrental_instance.public_ip_address
    port     = 5432
    username = google_sql_user.dvdrental_db_user.name
    password = random_password.dvdrental_db_password.result
    database = google_sql_database.dvdrental_db.name
  }
}

// 4. Datastream connection profile: BigQuery destination
resource "google_datastream_connection_profile" "bq_cp" {
  connection_profile_id = "dvdrental-bigquery-cp"
  display_name          = "dvdrental-bigquery-cp"
  location              = var.region
  bigquery_profile {}
}

// 5. Datastream Stream
resource "google_datastream_stream" "dvdrental_to_bq" {
  stream_id    = "dvdrental-to-bq-stream"
  display_name = "dvdrental PostgreSQL -> BigQuery"
  location     = var.region

  // Desired state required (RUNNING or PAUSED)
  desired_state = "RUNNING"

  source_config {
    source_connection_profile = google_datastream_connection_profile.postgres_cp.id

    postgresql_source_config {
      replication_slot = "dvdrental_slot"
      publication      = "dvdrental_publication"
      include_objects {
        postgresql_schemas {
          schema = "public"
        }
      }
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.bq_cp.id

    bigquery_destination_config {
      single_target_dataset {
        dataset_id = "${var.gcp_project_id}:${google_bigquery_dataset.dvdrental_bq.dataset_id}"
      }
    }
  }
  backfill_all {}
}
