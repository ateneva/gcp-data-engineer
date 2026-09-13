# PostgreSQL dvdrental Sample Database

## Connecting via `dvdrental` user

```bash
# 1. Print the generated password from your Terraform state
terraform output -raw db_password

# 2. Connect using the custom user
gcloud sql connect $(terraform output -raw instance_name) --user=dvdrental_user --project=$(terraform output -raw gcp_project_id)
```

## Inspecting the database

Once connected to the `dvdrental` database:

```sql
\dt
SELECT * FROM actor LIMIT 10;
```

---

## Datastream Setup: PostgreSQL to BigQuery

This project includes Terraform configuration to replicate the `dvdrental` database to BigQuery using Google Cloud Datastream.

### Architecture
- **Source**: Cloud SQL for PostgreSQL (`dvdrental` database).
- **Destination**: BigQuery (`dvdrental` dataset).
- **Method**: Change Data Capture (CDC) via PostgreSQL logical decoding.

### Prerequisite: Logical Decoding
The Cloud SQL instance is configured with the `cloudsql.logical_decoding` flag set to `on`.

### Manual Steps for PostgreSQL
After applying the Terraform configuration, you must connect to the PostgreSQL database and create the replication slot and publication if they don't exist:

```sql
-- 1. Create a publication for all tables
CREATE PUBLICATION dvdrental_publication FOR ALL TABLES;

-- 2. Create a logical replication slot
SELECT pg_create_logical_replication_slot('dvdrental_slot', 'pgoutput');
```

### Terraform Resources
- `google_bigquery_dataset.dvdrental_bq`: The target BigQuery dataset.

- `google_datastream_connection_profile.postgres_cp`: Connection profile for the source PostgreSQL.

- `google_datastream_connection_profile.bq_cp`: Connection profile for the destination BigQuery.

- `google_datastream_stream.dvdrental_to_bq`: The Datastream stream coordinating the replication.

## Resolving Import Errors & Data Mismatches

The `dvdrental` data import was addressed by fixing a **broken/incomplete SQL import file**.

### 1. Resolved Schema & Data Mismatch
The original `restore.sql` file was failing with `ERROR: relation "public.store" does not exist`. This happened because the file was structured as a series of `COPY` commands that expected external data files and a pre-existing schema.

To fix this, the following steps were taken:

*   **Extracted a Full Dump:** Downloaded `dvdrental.tar` (a standard PostgreSQL custom-format dump) from the GCS bucket.

*   **Converted to Plain SQL:** Used `pg_restore` locally to convert the binary dump into a single, self-contained `dvdrental_full.sql` file. This ensured that the schema (`CREATE TABLE`) and the data (`COPY ... FROM stdin`) were bundled together in the correct order.

*   **Sanitized for Cloud SQL Permissions:** Modified the generated SQL to remove commands that typically fail on managed Cloud SQL instances due to restricted permissions:

    *   **Removed `CREATE SCHEMA public`:** The `public` schema already exists, and the import user doesn't have permission to drop or recreate it.

    *   **Removed `CREATE EXTENSION plpgsql`:** This extension is pre-installed in Cloud SQL; attempting to recreate it causes a "must be owner" error.

*   **Updated Terraform Configuration:** Updated `import.tf` to point to the new, sanitized `dvdrental_full.sql` file.

### 3. Successful Import
The fixed SQL file was uploaded back to GCS and `terraform apply` was run. The `null_resource.dvdrental_import` successfully executed the `gcloud sql import` command, restoring the full `dvdrental` database schema and data.

---

## Resolving Datastream Connection & Configuration Errors

During the setup of the Datastream replication, several issues were addressed to ensure successful data flow.

### 1. Resolved Datastream Connection Timeout
The `google_datastream_connection_profile` was failing with a `CONNECTION_TIMEOUT`. This was caused by the Cloud SQL instance blocking connections from Datastream's public IP addresses.

*   **Solution:** Researched the Datastream public IP ranges for the `europe-west1` region and added them to the `authorized_networks` section of the `google_sql_database_instance` resource in `main.tf`.

*   **IPs added:** `104.199.6.64`, `34.78.213.130`, `35.205.33.30`, `35.205.125.111`, `35.187.27.174`.

### 2. Fixed BigQuery Dataset ID Format
The Datastream stream configuration was failing because the BigQuery dataset ID was provided in the wrong format.

*   **Solution:** Updated `datastream.tf` to use the required `projectId:datasetId` format for the `single_target_dataset.dataset_id` attribute.

### 3. PostgreSQL Replication Permissions & Setup
Datastream requires specific PostgreSQL roles and objects to be present for CDC to function correctly.

*   **Granting Replication Privilege:** The `dvdrental_user` was granted the `REPLICATION` attribute (`ALTER ROLE dvdrental_user WITH REPLICATION`).

*   **Manual Object Creation:** The `dvdrental_publication` and `dvdrental_slot` were manually created to ensure the stream could validate connectivity and begin the backfill process.