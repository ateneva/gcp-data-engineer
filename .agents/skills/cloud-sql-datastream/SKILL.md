---
name: cloud-sql-datastream
description: Creates Terraform Datastream pipelines from Cloud SQL MySQL, PostgreSQL, or SQL Server into BigQuery, following the Sakila, dvdrental, and AdventureWorks examples in this repository.
---

# Cloud SQL to BigQuery with Datastream

## MySQL Pattern

### 1. Prepare the MySQL database for streaming

- ensure log bins are enabled for the MySQL database to support change data capture (CDC). This is done in `cloud-sql/mysql/sakila/main.tf`.

```tf
    backup_configuration {
      enabled            = true
      binary_log_enabled = true # binary logs are needed for the stream to capture any CDC changes
      start_time         = "04:00"
    }

    database_flags {
      name  = "log_bin_trust_function_creators"
      value = "on"
    }
```

- create `datastream_user` with the `cloudsqlsuperuser` and  replication privileges to allow Datastream to read from the MySQL database. This is done in `cloud-sql/mysql/sakila/main.tf`.

```tf
resource "google_sql_user" "datastream_user" {
  name     = "sakilla_user"
  instance = google_sql_database_instance.mysql_instance.name
  password = random_password.db_password.result
  host     = "%"
}
```

```sql
CREATE USER IF NOT EXISTS 'sakilla_user'@'%';
GRANT SELECT, RELOAD, SHOW DATABASES, LOCK TABLES, REPLICATION CLIENT, REPLICATION SLAVE ON *.* TO 'sakilla_user'@'%';
FLUSH PRIVILEGES;
```

- ensure all needed tables have primary keys, as Datastream requires primary keys to stream data into BigQuery. This is done in `cloud-sql/mysql/sakila/grant_permissions.sql`.

---

## 2. Create Datastream admin and writer accounts

```tf
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
```

### 3. Create a BQ dataset to store the streamed data from Cloud SQL MySQL

> The dataset is created in `bigquery-dataset.tf`.

### 4. Create a Datastream connection profile to connect to the `Cloud SQL MySQL instance`

> The connection profile is created in `cloud-datastream/mysql-stream.tf`.

```tf
resource "google_datastream_connection_profile" "mysql_cp" {
  connection_profile_id = "mysql-cp"
  display_name          = "mysql-cp"
  location              = "eu-west1"

  mysql_profile {
    hostname = ""
    port     = 3306
    username = ""
    password = ""
  }
}
```

### 5. Create a Datastream connection profile to connect to the `BigQuery dataset`

> The connection profile is created in `cloud-datastream/mysql-stream.tf`.

```tf
resource "google_datastream_connection_profile" "bq_cp" {
  connection_profile_id = "bigquery-cp"
  display_name          = "bigquery-cp"
  location              = "eu-west1"
  bigquery_profile {}
}
```

### 6. Create a Datastream stream to connect the MySQL connection profile to the BigQuery connection profile

> The stream is created in `cloud-datastream/mysql-stream.tf`.

```tf
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
```

---

## PostgreSQL Pattern

---

## SQL Server Pattern

## Official Documentation

---

## FAQ
