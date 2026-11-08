locals {
  # Load and decode the YAML configuration file
  postgresql_config = yamldecode(file("${path.module}/postgresql-stream-config.yaml"))
}

resource "google_datastream_stream" "postgresql_to_bq" {
  stream_id    = local.postgresql_config.stream_id
  display_name = local.postgresql_config.display_name
  location     = local.postgresql_config.location

  desired_state = local.postgresql_config.desired_state

  source_config {
    source_connection_profile = google_datastream_connection_profile.postgres_cp.id

  postgresql_source_config {
        # PostgreSQL-specific mandatory parameters for Datastream
        replication_slot = local.postgresql_config.source.replication_slot
        publication      = local.postgresql_config.source.publication

        include_objects {
          postgresql_schemas {
            # PostgreSQL organizes objects by schema rather than database
            schema = lookup(local.postgresql_config.source, "schema", "public")

            # Dynamically loop through the tables listed in the YAML file
            dynamic "postgresql_tables" {
              for_each = local.postgresql_config.source.tables
              content {
                table = postgresql_tables.value
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
        dataset_id = local.postgresql_config.destination.dataset_id
      }

      # Dynamically render 'append_only' or 'merge' based on YAML configuration
      dynamic "append_only" {
        for_each = local.postgresql_config.destination.write_mode == "append" ? [1] : []
        content {}
      }

      dynamic "merge" {
        for_each = local.postgresql_config.destination.write_mode == "merge" ? [1] : []
        content {}
      }
    }
  }

  # Conditionally include backfill_all based on YAML configuration
  dynamic "backfill_all" {
    for_each = try(local.postgresql_config.backfill.enabled, false) ? [1] : []
    content {}
  }
}
