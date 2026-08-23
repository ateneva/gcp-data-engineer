# PostgreSQL dvdrental Sample Database

## Connect via `dvdrental` user

```bash
# 1. Print the generated password from your Terraform state
terraform output -raw db_password

# 2. Connect using the custom user
gcloud sql connect $(terraform output -raw instance_name) --user=dvdrental_user --project=$(terraform output -raw gcp_project_id)
```

## Inspect the database

Once connected to the `dvdrental` database:

```sql
\dt
SELECT * FROM actor LIMIT 10;
```
