# MySQL Airport Sample Database

## Connect via `airport` user

```bash
# 1. Print the generated password from your Terraform state
terraform output -raw airport_db_password

# 2. Connect using the custom user
gcloud sql connect mysql-airport-db-2aaa1739 --user=airport_user --project=data-geeking-gcp
```

## Inspect the database

```sql
show databases;
use airport;
show tables;
```

```text
mysql> show tables;
+----------------------+
| Tables_in_airport_db |
+----------------------+
| airline              |
| airplane             |
| airplane_type        |
| airport              |
| airport_geo          |
| airport_reachable    |
| employee             |
| flight               |
| flight_log           |
| flightschedule       |
| passenger            |
| passengerdetails     |
| weatherdata          |
+----------------------+
13 rows in set (0.01 sec)
```
