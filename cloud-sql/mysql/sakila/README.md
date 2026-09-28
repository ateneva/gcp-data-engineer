# MySQL Sakila Sample Database

- [MySQL Sakila Sample Database](#mysql-sakila-sample-database)
  - [Connecting via `root` user](#connecting-via-root-user)
  - [Connecting via `sakilla` user](#connecting-via-sakilla-user)
  - [Setting Up a Datastream to BigQuery](#setting-up-a-datastream-to-bigquery)
    - [Enable Datastream API](#enable-datastream-api)
    - [Set up Connection Profiles](#set-up-connection-profiles)
    - [Create Stream](#create-stream)
    - [Set up permissiions for the MySQL user](#set-up-permissiions-for-the-mysql-user)
    - [Deployment](#deployment)

## Connecting via `root` user

```bash
## generic command to connect to the Cloud SQL instance using the `root` user
gcloud sql connect < instance name > --user=root --project=data-geeking-gcp

## Example command to connect to the Cloud SQL instance using the `root` user
gcloud sql connect mysql-sakilla-db-036eeb9d --user=root --project=data-geeking-gcp
```

## Connecting via `sakilla` user

```bash
# 1. Print the generated password from your Terraform state
terraform output -raw db_password

# 2. Connect using the custom user
gcloud sql connect mysql-sakilla-db-036eeb9d --user=sakilla_user --project=data-geeking-gcp
```

---

## Setting Up a Datastream to BigQuery

This project now includes a Terraform configuration (`datastream.tf`) to stream data from the MySQL Sakila database to BigQuery in real-time.

### Enable Datastream API

```bash
gcloud services enable datastream.googleapis.com
```

### Set up Connection Profiles

- `sakila-mysql-source`
  > Connects to the Cloud SQL instance using the `sakilla_user` and authorized Datastream IPs for `europe-west1`

- `sakila-bigquery-cp`
  > Connects to BigQuery.

### Create Stream

> Synchronizes the `sakila` database to the `sakila_datastream` BigQuery dataset.

### Set up permissiions for the MySQL user

> Automatically grants `REPLICATION CLIENT` and `REPLICATION SLAVE` permissions to the MySQL user via an automated SQL import during deployment.

### Deployment

1. Ensure you have `datastream.tf` and `grant_permissions.sql` in the directory

2. Run `terraform apply`

3. The stream will automatically start in a `RUNNING` state, performing an initial backfill before switching to CDC (Change Data Capture) mode.
