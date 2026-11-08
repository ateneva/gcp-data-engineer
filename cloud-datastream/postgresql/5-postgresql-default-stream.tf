// Datastream: dvdrental PostgreSQL -> BigQuery

// 5. Datastream Stream
resource "google_datastream_stream" "dvdrental_to_bq" {
  stream_id    = "dvdrental-to-bq-stream"
  display_name = "dvdrental-to-bq-stream"
  location     = "europe-west1"

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
        dataset_id = "projects/data-geeking-gcp/datasets/dvdrental"
      }
    }
  }
  backfill_all {}
}
