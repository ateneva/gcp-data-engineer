# MySQL Streaming Prerequisites

## GCP Setup

The following GCP infrastructure must be in place before a stream can be created:

- bigquery dataset where data will be replicated
- datastream service account with the following permissions

```plaintxt
roles/bigquery.dataEditor
roles/datastream.admin
```

- datastream connection profile and MySQL database connection 

---

## MySQL Setup

- mysql db exists
- binlog replication has been enabled

```tf
    database_flags {
      name  = "log_bin_trust_function_creators"
      value = "on"
    }
```

- datastream user has been created with the following privileges

```sql
CREATE USER 'datastream'@'%' IDENTIFIED BY 'YOUR_PASSWORD';
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'datastream'@'%';
FLUSH PRIVILEGES;
```

- primary keys have been defined for the tables being replicated

```sql
-- Add primary key to the customer table
ALTER TABLE customer ADD PRIMARY KEY (customer_id);

-- Add primary key to the payment table
ALTER TABLE payment ADD PRIMARY KEY (payment_id);
```

---

## Stream Defaults

The snippet below will: 
- create a stream for ALL tables from the specified database
- ALL tables will be backfilled upon stream creation
- `WRITE` mode for new records will be `MERGE` for ALL tables


```tf
// 5. Create a Datastream Stream
resource "google_datastream_stream" "sakila_to_bq" {
  stream_id    = "sakila-to-bq-stream"
  display_name = "Sakila -> BigQuery"
  location     = var.region

  // Desired state required (RUNNING or PAUSED)
  desired_state = "RUNNING"

  source_config {
    source_connection_profile = "sakila-mysql-cp"

    mysql_source_config {
      include_objects {
        mysql_databases {
          database = "sakila"
        }
      }
    }
  }

  destination_config {
    destination_connection_profile = "sakila-bigquery-cp"

    bigquery_destination_config {
      single_target_dataset {
        dataset_id = "projects/data-geeking-gcp/datasets/sakila"
      }
    }
  }
  backfill_all {}
}
```

---

## More info

- https://docs.cloud.google.com/datastream/docs/sources-mysql

- https://docs.cloud.google.com/datastream/docs/configure-cloudsql-mysql