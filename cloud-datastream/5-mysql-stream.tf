locals {
  # Load and decode the YAML configuration file
  config = yamldecode(file("${path.module}/mysql-stream-config.yaml"))
}

resource "google_datastream_stream" "mysql_to_bq" {
  stream_id    = local.config.stream_id
  display_name = local.config.display_name
  location     = local.config.location

  desired_state = local.config.desired_state

  source_config {
    source_connection_profile = google_datastream_connection_profile.mysql_cp.id

    mysql_source_config {
      include_objects {
        mysql_databases {
          database = local.config.source.database
          
          # Dynamically loop through the tables listed in the YAML file
          dynamic "mysql_tables" {
            for_each = local.config.source.tables
            content {
              table = mysql_tables.value
            }
          }
        }
      }
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.bq_cp.id

    bigquery_destination_config {
      single_target_dataset {
        dataset_id = local.config.destination.dataset_id
      }

      # Dynamically render 'append_only' or 'merge' based on YAML configuration
      dynamic "append_only" {
        for_each = local.config.destination.write_mode == "append" ? [1] : []
        content {}
      }

      dynamic "merge" {
        for_each = local.config.destination.write_mode == "merge" ? [1] : []
        content {}
      }
    }
  }

  # Conditionally include backfill_all based on YAML configuration
  dynamic "backfill_all" {
    for_each = try(local.config.backfill.enabled, false) ? [1] : []
    content {}
  }
}