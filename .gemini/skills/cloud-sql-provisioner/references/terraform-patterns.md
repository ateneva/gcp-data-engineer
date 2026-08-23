# Terraform Patterns for Cloud SQL Provisioning and Import

This reference provides idiomatic Terraform patterns for creating Google Cloud SQL instances and importing data from Cloud Storage.

## 1. Cloud SQL Instance with Random Suffix
Cloud SQL instance names cannot be reused immediately after deletion. Always use a random suffix.

```hcl
resource "random_id" "db_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  name             = "${var.db_name_prefix}-${random_id.db_suffix.hex}"
  database_version = "MYSQL_8_0" # Or POSTGRES_15, SQLSERVER_2019_STANDARD, etc.
  region           = var.region
  deletion_protection = false # Set to true for production

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = true
    }
    backup_configuration {
      enabled = true
    }
  }
}
```

## 2. Database and User
```hcl
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.instance.name
}

resource "random_password" "password" {
  length  = 16
  special = true
}

resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.instance.name
  password = random_password.password.result
}
```

## 3. Data Import via gcloud (local-exec)
Importing data often requires granting the Cloud SQL service account read access to the source bucket.

```hcl
resource "google_storage_bucket_iam_member" "import_grant" {
  bucket = var.import_bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_sql_database_instance.instance.service_account_email_address}"
}

resource "null_resource" "db_import" {
  triggers = {
    instance_id = google_sql_database_instance.instance.id
    # Add file hashes if tracking specific files
  }

  provisioner "local-exec" {
    command = <<EOT
      gcloud sql import sql ${google_sql_database_instance.instance.name} \
        gs://${var.import_bucket_name}/${var.import_file_path} \
        --database=${google_sql_database.database.name} \
        --project=${var.gcp_project_id} \
        --quiet
    EOT
  }

  depends_on = [
    google_sql_database_instance.instance,
    google_sql_database.database,
    google_storage_bucket_iam_member.import_grant
  ]
}
```

## 4. Multi-file Import Pattern
If importing multiple files, use `for_each` or a loop in `local-exec`.

```hcl
locals {
  sql_files = ["file1.sql", "file2.sql"]
}

resource "null_resource" "multi_import" {
  # ... triggers ...
  provisioner "local-exec" {
    command = <<EOT
      %{for file in local.sql_files~}
      gcloud sql import sql ${google_sql_database_instance.instance.name} \
        gs://${var.import_bucket_name}/${file} \
        --database=${google_sql_database.database.name} \
        --project=${var.gcp_project_id} \
        --no-async \
        --quiet
      %{endfor~}
    EOT
  }
  # ... depends_on ...
}
```
