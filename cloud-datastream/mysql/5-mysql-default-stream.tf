
// 5. Create a Datastream Stream
resource "google_datastream_stream" "sakila_to_bq" {
  stream_id    = "sakila-to-bq-stream"
  display_name = "sakila-to-bq-stream"
  location     = "europe-west1"

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
        dataset_id = "projects/data-geeking-gcp/datasets/sakila"
      }
    }
  }
  backfill_all {}
}
