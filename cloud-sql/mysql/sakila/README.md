# MySQL Sakila Sample Database on Cloud SQL

- [MySQL Sakila Sample Database on Cloud SQL](#mysql-sakila-sample-database-on-cloud-sql)
  - [Resources and data flow](#resources-and-data-flow)
  - [Verify the database creation](#verify-the-database-creation)
  - [Connect via `sakilla` user](#connect-via-sakilla-user)
  - [Setting Up a Datastream to BigQuery](#setting-up-a-datastream-to-bigquery)
    - [Enable Datastream API](#enable-datastream-api)
    - [Set up Connection Profiles](#set-up-connection-profiles)
    - [Create Stream](#create-stream)
    - [Set up permissiions for the MySQL user](#set-up-permissiions-for-the-mysql-user)
    - [Deployment](#deployment)
  - [Outputs and teardown](#outputs-and-teardown)

This Terraform configuration creates a Cloud SQL for MySQL 8.4 instance, loads
the Sakila sample database from Cloud Storage, and configures Datastream to
replicate the database into BigQuery.

## Resources and data flow

- A `db-f1-micro` Cloud SQL instance named `mysql-sakila-db-<random-suffix>`,
  in `europe-west1` by default, with a public IPv4 address

- A `sakila` database and a `sakilla_user` account with a generated password
  The account is created for both `%` and `localhost` hosts

- Cloud Storage object-viewer access for the Cloud SQL service account, followed
  by sequential schema and data imports from:
  `gs://data-engineer-in-training/gcp/databases/sakila-db/`

- The SQL import objects and source bucket are currently fixed in `import.tf`.

---

## Verify the database creation

```bash
terraform output

### output
db_password = <sensitive>
db_username = "sakilla_user"
instance_connection_name = "data-geeking-gcp:europe-west1:mysql-sakila-db-d859ecce"
instance_name = "mysql-sakila-db-d859ecce"
public_ip_address = "104.199.84.229"
```

![MySQL Instance](img/2026-09-28-15.28.36-mysql-instance.png)

![MySQL Instance Specs](img/2026-09-28-15.28.37-mysql-instance-specs.png)

![Connect to MySQL Instance](img/2026-09-28-15.28.38-connect-to-mysql-instance.png)

---

## Connect via `sakilla` user

```bash
# 1. Print the generated password from your Terraform state
terraform output -raw db_password

# 2. Export MySQL instance name dynamically from Terraform:
export MYSQL_INSTANCE=$(terraform output -raw instance_name)

# 3. Verify the variable
echo $MYSQL_INSTANCE

# 4. Connect using the exported variable
gcloud sql connect "$MYSQL_INSTANCE" --user=sakilla_user --project=data-geeking-gcp

# 2. Connect using the custom user
gcloud sql connect INSTANCE_NAME --user=sakilla_user --project=data-geeking-gcp
```

![MySQL Database Users](img/2026-09-2815.31.04-mysql-db-users.png)

![MySQL Instance Databases](img/2026-09-2815.31.23-mysql-instance-dbs.png)

---

## Outputs and teardown

To inspect all created resources, run:

```bash
terraform output
```

```bash
tenevaa21@cloudshell:~/gcp-data-engineer/cloud-sql/mysql/sakila (data-geeking-gcp)$ terraform output
datastream_bigquery_connection_profile_id = "projects/data-geeking-gcp/locations/europe-west1/connectionProfiles/sakila-bigquery-cp"
datastream_bigquery_dataset_id = "sakila"
datastream_mysql_connection_profile_id = "projects/data-geeking-gcp/locations/europe-west1/connectionProfiles/sakila-mysql-cp"
datastream_service_account_email = "datastream-sa@data-geeking-gcp.iam.gserviceaccount.com"
datastream_staging_bucket_name = "data-geeking-gcp-datastream-staging-cf40743e"
datastream_staging_bucket_url = "gs://data-geeking-gcp-datastream-staging-cf40743e"
datastream_stream_id = "projects/data-geeking-gcp/locations/europe-west1/streams/sakila-to-bq-stream"
datastream_stream_name = "sakila-to-bq-stream"
datastream_stream_state = "RUNNING"
db_password = <sensitive>
db_username = "sakilla_user"
instance_connection_name = "data-geeking-gcp:europe-west1:mysql-sakila-db-d859ecce"
instance_name = "mysql-sakila-db-d859ecce"
public_ip_address = "104.199.84.229"

```

To remove ALL created resources:

```bash
terraform destroy

tenevaa21@cloudshell:~/gcp-data-engineer/cloud-sql/mysql/sakila (data-geeking-gcp)$ terraform destroy
```

The Cloud SQL instance has deletion protection disabled for this
development-oriented setup. The Datastream staging bucket is configured with
`force_destroy`, so its objects are deleted along with the bucket.
