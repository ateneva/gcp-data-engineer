# Setup Prerequisites

- [Setup Prerequisites](#setup-prerequisites)
  - [PostgreSQL Streaming Prerequisites](#postgresql-streaming-prerequisites)
  - [GCP Streaming Prerequisites](#gcp-streaming-prerequisites)
  - [Stream Defaults](#stream-defaults)
  - [More info](#more-info)

## PostgreSQL Streaming Prerequisites

- postgresql db exists
- logical replication has been enabled

```tf
    database_flags {
      name  = "cloudsql.logical_decoding"
      value = "on"
    }
```

- datastream db user has been created
- datastream user has usage privilesges on needed tables and schemas

```sql
--- 1. Create replication user
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'datastream_user') 
    THEN
        CREATE USER datastream_user WITH REPLICATION PASSWORD 'your_secure_password';
    END IF
END
$$;

--- 2. Grant table and schema privileges to datastream user
GRANT USAGE ON SCHEMA public TO datastream_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO datastream_user;

--- 3. Ensure datastream_user can read future tables created in public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO datastream_user;
```

- publication and replication slots have been created

```sql
--- 1. Create publication for all tables
--- publication must be unique per stream
CREATE PUBLICATION dvdrental_publication FOR ALL TABLES;

--- 2. Create replication slot
--- replication slot must be unique per stream
SELECT pg_create_logical_replication_slot('dvdrental_slot', 'pgoutput');

```

- primary keys have been defined for the tables being replicated
  > NB! Missing primary keys will result in streaming errors

```sql
-- Add primary key to the customer table
ALTER TABLE customer ADD PRIMARY KEY (customer_id);

-- Add primary key to the payment table
ALTER TABLE payment ADD PRIMARY KEY (payment_id);
```

---

## GCP Streaming Prerequisites

The following GCP infrastructure must be in place before a stream can be created:

- bigquery dataset where data will be replicated
- datastream service account with the following permissions

```plaintxt
roles/bigquery.dataEditor
roles/datastream.admin
```

- datastream connection profile and PostgreSQL database connection

  - Example of a PostgreSQL connection profile can be found on `cloud-datastream/postgresql/3-postgresql-stream-connection.tf`

> Note that `PostgreSQL` requires `database` name to be specified in the `postgresql_profile` connection configuration

```tf
  postgresql_profile {
    hostname = var.postgresql_hostname
    port     = 5432
    username = var.postgresql_username
    password = var.postgresql_password
    database = var.postgresql_db
  }
```

---

## Stream Defaults

Example of a default sstream configuration for PostgreSQL to BigQuery replication can be found on `cloud-datastream/postgresql/5-postgresql-default-stream.tf`

This configuration will:

- create a stream for ALL tables from the specified database
- ALL tables will be backfilled upon stream creation
- `WRITE` mode for new records will be `MERGE` for ALL tables

> Note the `PostgreSQL` specifics in the source_config

```tf
    postgresql_source_config {
      replication_slot = "dvdrental_slot"
      publication      = "dvdrental_publication"
      include_objects {
        postgresql_schemas {
          schema = "public"
        }
      }
    }
```

---

## More info

- <https://docs.cloud.google.com/datastream/docs/configure-cloudsql-psql>

- <https://docs.cloud.google.com/sql/docs/postgres/replication/configure-logical-replication#configure-your-postgresql-instance>

- <https://docs.cloud.google.com/sql/docs/postgres/replication/configure-logical-replication>
