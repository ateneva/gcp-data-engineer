# MySQL Sakila Sample Database

## Connecting via `root` user

```bash
gcloud sql connect mysql-sakilla-db-036eeb9d --user=root --project=data-geeking-gcp
```

## Connecting via `sakilla` user

```bash
# 1. Print the generated password from your Terraform state
terraform output -raw db_password

# 2. Connect using the custom user
gcloud sql connect mysql-sakilla-db-036eeb9d --user=sakilla_user --project=data-geeking-gcp
```

## Setting Up a Datastream to BigQuery

This project now includes a Terraform configuration (`datastream.tf`) to stream data from the MySQL Sakila database to BigQuery in real-time.

### Key Components

*   **Datastream API**: Enabled automatically via Terraform.

*   **Connection Profiles**: 
    *   `sakila-mysql-source`: Connects to the Cloud SQL instance using the `sakilla_user` and authorized Datastream IPs for `europe-west1`.
    *   `bq-destination`: Connects to BigQuery.
    
*   **Stream**: Synchronizes the `sakilla_db` database to the `sakila_datastream` BigQuery dataset.

*   **Permissions**: Automatically grants `REPLICATION CLIENT` and `REPLICATION SLAVE` permissions to the MySQL user via an automated SQL import during deployment.

### Deployment

1.  Ensure you have `datastream.tf` and `grant_permissions.sql` in the directory.
2.  Run `terraform apply`.
3.  The stream will automatically start in a `RUNNING` state, performing an initial backfill before switching to CDC (Change Data Capture) mode.

