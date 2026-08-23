# PostgreSQL dvdrental Sample Database

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
