# 1. Fetch the Cloud Storage bucket and SQL dump object
data "google_storage_bucket_object" "sakila-schema" {
  name   = "gcp/databases/sakila-db/sakila-schema.sql" # Folder path goes here if inside subfolders
  bucket = "data-engineer-in-training"      # Bucket name ONLY (no slashes)
}

data "google_storage_bucket_object" "sakila-data" {
  name   = "gcp/databases/sakila-db/sakila-data.sql" # Folder path goes here if inside subfolders
  bucket = "data-engineer-in-training"      # Bucket name ONLY (no slashes)
}

# 2. Grant the Cloud SQL service account access to read from the bucket
resource "google_storage_bucket_iam_member" "sql_import_grant" {
  bucket = "data-engineer-in-training"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_sql_database_instance.mysql_instance.service_account_email_address}"
}

# 3. Execute the schema import command after instance, database, and IAM permissions exist
resource "null_resource" "db_schema_import" {
  # Trigger the import if the bucket object (file md5/version) changes or instance changes
  triggers = {
    sql_file_hash = data.google_storage_bucket_object.sakila-schema.md5hash
    instance_id   = google_sql_database_instance.mysql_instance.id
  }

  provisioner "local-exec" {
    command = <<EOT
      gcloud sql import sql ${google_sql_database_instance.mysql_instance.name} \
        gs://${data.google_storage_bucket_object.sakila-schema.bucket}/${data.google_storage_bucket_object.sakila-schema.name} \
        --database=${google_sql_database.sakilla_db.name} \
        --project=${var.gcp_project_id} \
        --quiet
    EOT
  }

  depends_on = [
    google_sql_database_instance.mysql_instance,
    google_sql_database.sakilla_db,
    google_storage_bucket_iam_member.sql_import_grant
  ]
}

# 4. Execute the data import command after instance, database, and IAM permissions exist
resource "null_resource" "db_data_import" {
  # Trigger the import if the bucket object (file md5/version) changes or instance changes
  triggers = {
    sql_file_hash = data.google_storage_bucket_object.sakila-data.md5hash
    instance_id   = google_sql_database_instance.mysql_instance.id
  }

  provisioner "local-exec" {
    command = <<EOT
      gcloud sql import sql ${google_sql_database_instance.mysql_instance.name} \
        gs://${data.google_storage_bucket_object.sakila-data.bucket}/${data.google_storage_bucket_object.sakila-data.name} \
        --database=${google_sql_database.sakilla_db.name} \
        --project=${var.gcp_project_id} \
        --quiet
    EOT
  }

  depends_on = [
    google_sql_database_instance.mysql_instance,
    google_sql_database.sakilla_db,
    google_storage_bucket_iam_member.sql_import_grant,
    null_resource.db_schema_import
  ]
}