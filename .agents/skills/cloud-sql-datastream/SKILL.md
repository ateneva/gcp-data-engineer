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
>
> The dataset is created in `bigquery-dataset.tf`.

### 4. Create a Datastream connection profile to connect to the `Cloud SQL MySQL instance`
>
> The connection profile is created in `cloud-datastream/mysql-stream.tf`.

```tf
resource "google_datastream_connection_profile" "mysql_cp" {
  connection_profile_id = "sakila-mysql-cp"
  display_name          = "sakila-mysql-cp"
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
>
> The connection profile is created in `cloud-datastream/mysql-stream.tf`.

```tf
resource "google_datastream_connection_profile" "bq_cp" {
  connection_profile_id = "sakila-bigquery-cp"
  display_name          = "sakila-bigquery-cp"
  location              = "eu-west1"
  bigquery_profile {}
}
```

### 6. Create a Datastream stream to connect the MySQL connection profile to the BigQuery connection profile
>
> The stream is created in `cloud-datastream/mysql-stream.tf`.

```tf

```

---

## PostgreSQL Pattern

---

## SQL Server Pattern

## Official Documentation

---

## FAQ
