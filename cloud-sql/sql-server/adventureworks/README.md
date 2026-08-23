# AdventureWorks DW 2017 SQL Server Setup

This Terraform configuration creates a Google Cloud SQL instance for SQL Server 2017 and imports the AdventureWorksDW2017 database from a `.bak` file stored in Google Cloud Storage.

## Resources Created

- **Google Cloud SQL Instance**: SQL Server 2017 Standard edition.
- **SQL User**: A superuser (`sqlserver`) with a randomly generated password.
- **IAM Binding**: Grants the Cloud SQL service account read access to the GCS bucket containing the `.bak` file.
- **Import Job**: Uses `gcloud sql import bak` to restore the database.

## Usage

1.  Initialize Terraform:
    ```bash
    terraform init
    ```

2.  Apply the configuration:
    ```bash
    terraform apply
    ```

3.  The import process is handled via a `null_resource` using `local-exec`. Ensure you have `gcloud` authenticated and configured with the correct project.

## Note on SQL Server Tiers

SQL Server requires more resources than MySQL or PostgreSQL. This configuration uses `db-custom-2-3840` (2 vCPUs, 3.75 GB RAM) as a minimum viable tier for development.


## Get generated credentials

```bash
# 1. Print the generated password from your Terraform state
terraform output -raw sa_password
