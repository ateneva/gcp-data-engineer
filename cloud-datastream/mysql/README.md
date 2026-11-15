# Setup Prerequisites

- [Setup Prerequisites](#setup-prerequisites)
  - [MySQL Streaming Prerequisites](#mysql-streaming-prerequisites)
  - [GCP Streaming Prerequisites](#gcp-streaming-prerequisites)
  - [Stream Defaults](#stream-defaults)
  - [More info](#more-info)

## MySQL Streaming Prerequisites

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

- Datastream connection profiles are defined by YAML files in
  `cloud-datastream/mysql/connections/`. Each file creates one MySQL profile.
  The filename without `.yaml` is the key used for credentials and Terraform
  references (for example, `sakila.yaml` is keyed as `sakila`).

  - Replace the sample hostname and copy `sakila.yaml` to add another
    connection, then set its profile ID, display name, location, hostname, and
    port.
  - Supply credentials through the sensitive `mysql_connection_credentials`
    Terraform variable, keyed by each YAML filename. Supply it through an
    untracked tfvars file or a secrets pipeline; do not put passwords in YAML.
  - Set `source.connection` in `mysql-stream-config.yaml` for the default
    stream. Each custom stream selects its connection through `source.connection`
    in its stream YAML file.

```hcl
mysql_connection_credentials = {
  sakila = {
    username = "datastream"
    password = "<set-through-a-secret-safe-variable-source>"
  }
}
```

- Custom stream definitions are loaded from
  `cloud-datastream/mysql/streams/*.yaml`. Copy `streams/sakila.yaml` to define
  another stream; each file creates one stream and uses its filename (without
  `.yaml`) as the Terraform instance key.

---

## Stream Defaults

Example of a default sstream configuration for PostgreSQL to BigQuery replication can be found on `cloud-datastream/mysql/5-mysql-default-stream.tf`

This configuration will:

- create a stream for ALL tables from the specified database
- ALL tables will be backfilled upon stream creation
- `WRITE` mode for new records will be `MERGE` for ALL tables

> Note the `MySQL` specifics in the source_config

```tf
    mysql_source_config {
      include_objects {
        mysql_databases {
          database = "sakila"
        }
      }
    }
```

---

## More info

- <https://docs.cloud.google.com/datastream/docs/sources-mysql>

- <https://docs.cloud.google.com/datastream/docs/configure-cloudsql-mysql>
