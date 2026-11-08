# PostgreSQL dvdrental Sample Database

- [PostgreSQL dvdrental Sample Database](#postgresql-dvdrental-sample-database)
  - [Connecting via `dvdrental` user](#connecting-via-dvdrental-user)
  - [Inspecting the database](#inspecting-the-database)
  - [Datastream Setup: PostgreSQL to BigQuery](#datastream-setup-postgresql-to-bigquery)
    - [Architecture](#architecture)
    - [Prerequisite: Logical Decoding](#prerequisite-logical-decoding)
    - [Manual Steps for PostgreSQL](#manual-steps-for-postgresql)
    - [Terraform Resources](#terraform-resources)
  - [Resolving Import Errors \& Data Mismatches](#resolving-import-errors--data-mismatches)
    - [1. Resolved Schema \& Data Mismatch](#1-resolved-schema--data-mismatch)
    - [3. Successful Import](#3-successful-import)
  - [Resolving Datastream Connection \& Configuration Errors](#resolving-datastream-connection--configuration-errors)
    - [1. Resolved Datastream Connection Timeout](#1-resolved-datastream-connection-timeout)
    - [2. Fixed BigQuery Dataset ID Format](#2-fixed-bigquery-dataset-id-format)
    - [3. PostgreSQL Replication Permissions \& Setup](#3-postgresql-replication-permissions--setup)
  - [Ouptuts and resource cleanup](#ouptuts-and-resource-cleanup)
    - [Ouputs](#ouputs)
    - [Resource cleanup](#resource-cleanup)

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
SELECT * FROM actor ;
```

---

## Resolving Import Errors & Data Mismatches

The `dvdrental` data import was addressed by fixing a **broken/incomplete SQL import file**.

### 1. Resolved Schema & Data Mismatch

The original `restore.sql` file was failing with `ERROR: relation "public.store" does not exist`. This happened because the file was structured as a series of `COPY` commands that expected external data files and a pre-existing schema.

To fix this, the following steps were taken:

- **Extracted a Full Dump:** Downloaded `dvdrental.tar` (a standard PostgreSQL custom-format dump) from the GCS bucket.

- **Converted to Plain SQL:** Used `pg_restore` locally to convert the binary dump into a single, self-contained `dvdrental_full.sql` file. This ensured that the schema (`CREATE TABLE`) and the data (`COPY ... FROM stdin`) were bundled together in the correct order.

- **Sanitized for Cloud SQL Permissions:** Modified the generated SQL to remove commands that typically fail on managed Cloud SQL instances due to restricted permissions:

    - **Removed `CREATE SCHEMA public`:** The `public` schema already exists, and the import user doesn't have permission to drop or recreate it.

    - **Removed `CREATE EXTENSION plpgsql`:** This extension is pre-installed in Cloud SQL; attempting to recreate it causes a "must be owner" error.

- **Updated Terraform Configuration:** Updated `import.tf` to point to the new, sanitized `dvdrental_full.sql` file.

### 3. Successful Import

The fixed SQL file was uploaded back to GCS and `terraform apply` was run. The `null_resource.dvdrental_import` successfully executed the `gcloud sql import` command, restoring the full `dvdrental` database schema and data.

---

## Ouptuts and resource cleanup

### Ouputs

```bash
tenevaa21@cloudshell:~/gcp-data-engineer/cloud-sql/postgresql/dvdrental (data-geeking-gcp)$ terraform output
connection_name = "data-geeking-gcp:europe-west1:postgres-dvdrental-db-0fd7884f"
datastream_bigquery_connection_profile_id = "projects/data-geeking-gcp/locations/europe-west1/connectionProfiles/dvdrental-bigquery-cp"
datastream_bigquery_dataset_id = "dvdrental"
datastream_db_password = <sensitive>
datastream_db_user = "datastream_user"
datastream_postgres_connection_profile_id = "projects/data-geeking-gcp/locations/europe-west1/connectionProfiles/dvdrental-postgres-cp"
datastream_service_account_email = "datastream-sa-dvdrental@data-geeking-gcp.iam.gserviceaccount.com"
datastream_stream_id = "projects/data-geeking-gcp/locations/europe-west1/streams/dvdrental-to-bq-stream"
datastream_stream_name = "dvdrental-to-bq-stream"
datastream_stream_state = "RUNNING"
db_name = "dvdrental"
db_password = <sensitive>
db_user = "dvdrental_user"
db_username = "dvdrental_user"
gcp_project_id = "data-geeking-gcp"
instance_connection_name = "data-geeking-gcp:europe-west1:postgres-dvdrental-db-0fd7884f"
instance_name = "postgres-dvdrental-db-0fd7884f"
instance_service_account_email = "p275589915638-3anxvn@gcp-sa-cloud-sql.iam.gserviceaccount.com"
postgresql_publication_name = "dvdrental_publication"
postgresql_replication_slot_name = "dvdrental_slot"
public_ip_address = "34.140.143.126"
tenevaa21@cloudshell:~/gcp-data-engineer/cloud-sql/postgresql/dvdrental (data-geeking-gcp)$
```

### Resource cleanup

```bash
# Step 1: Destroy Datastream pipeline resources first
terraform destroy \
  -target="google_datastream_stream.dvdrental_to_bq" \
  -target="google_datastream_connection_profile.postgres_cp" \
  -target="google_datastream_connection_profile.bq_cp"

# Step 2: Destroy PostgreSQL CDC replication objects
terraform destroy \
  -target="postgresql_publication.dvdrental_pub" \
  -target="postgresql_replication_slot.dvdrental_slot"

# Step 3: Destroy BigQuery destination dataset and Service Accounts
terraform destroy \
  -target="google_bigquery_dataset.dvdrental_bq" \
  -target="google_service_account.datastream_sa"

# Step 4: Destroy Cloud SQL instance, database, users, and secrets
terraform destroy \
  -target="google_sql_database.dvdrental_db" \
  -target="google_sql_user.dvdrental_db_user" \
  -target="google_sql_user.datastream_user" \
  -target="google_sql_database_instance.postgres_dvdrental_instance" \
  -target="random_password.dvdrental_db_password" \
  -target="random_password.datastream_db_password"
```
