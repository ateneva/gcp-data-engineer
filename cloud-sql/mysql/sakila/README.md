# MySQL Sakila Sample Database

## Connect via `root` user

```bash
gcloud sql connect mysql-sakilla-db-036eeb9d --user=root --project=data-geeking-gcp
```

## Connect via `sakilla` user

```bash
# 1. Print the generated password from your Terraform state
terraform output -raw db_password

# 2. Connect using the custom user
gcloud sql connect mysql-sakilla-db-036eeb9d --user=sakilla_user --project=data-geeking-gcp
```
