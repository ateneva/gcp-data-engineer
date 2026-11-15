locals {
  mysql_stream_configs = {
    for file in fileset(path.module, "streams/*.yaml") :
    trimsuffix(basename(file), ".yaml") => yamldecode(file("${path.module}/${file}"))
  }
}

resource "google_datastream_stream" "mysql_to_bq" {
  for_each = local.mysql_stream_configs

  stream_id    = each.value.stream_id
  display_name = each.value.display_name
  location     = each.value.location

  desired_state = each.value.desired_state

  source_config {
    source_connection_profile = google_datastream_connection_profile.mysql_cp[each.value.source.connection].id

    mysql_source_config {
      include_objects {
        mysql_databases {
          database = each.value.source.database

          # Dynamically loop through the tables listed in the YAML file
          dynamic "mysql_tables" {
            for_each = each.value.source.tables
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
        dataset_id = each.value.destination.dataset_id
      }

      # Dynamically render 'append_only' or 'merge' based on YAML configuration
      dynamic "append_only" {
        for_each = each.value.destination.write_mode == "append" ? [1] : []
        content {}
      }

      dynamic "merge" {
        for_each = each.value.destination.write_mode == "merge" ? [1] : []
        content {}
      }
    }
  }

  # Conditionally include backfill_all based on YAML configuration
  dynamic "backfill_all" {
    for_each = try(each.value.backfill.enabled, false) ? [1] : []
    content {}
  }

  dynamic "backfill_none" {
    for_each = try(each.value.backfill.enabled, false) ? [] : [1]
    content {}
  }
}

