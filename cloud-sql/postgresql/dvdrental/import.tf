# 1. Fetch Cloud Storage object for the SQL restore file
data "google_storage_bucket_object" "dvdrental_restore" {
  name   = "gcp/databases/dvdrental/dvdrental_full.sql"
  bucket = "data-engineer-in-training"
}

# 2. Grant the Cloud SQL service account access to read from the bucket
resource "google_storage_bucket_iam_member" "import_dvdrental_grant" {
  bucket = "data-engineer-in-training"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_sql_database_instance.postgres_dvdrental_instance.service_account_email_address}"
}

# 3. Execute the import command
resource "null_resource" "dvdrental_import" {
  triggers = {
    sql_file_hash = data.google_storage_bucket_object.dvdrental_restore.md5hash
    instance_id   = google_sql_database_instance.postgres_dvdrental_instance.id
  }

  provisioner "local-exec" {
    command = <<EOT
      gcloud sql import sql ${google_sql_database_instance.postgres_dvdrental_instance.name} \
        gs://${data.google_storage_bucket_object.dvdrental_restore.bucket}/${data.google_storage_bucket_object.dvdrental_restore.name} \
        --database=${google_sql_database.dvdrental_db.name} \
        --project=${var.gcp_project_id} \
        --quiet
    EOT
  }

  depends_on = [
    google_sql_database_instance.postgres_dvdrental_instance,
    google_sql_database.dvdrental_db,
    google_storage_bucket_iam_member.import_dvdrental_grant,
    data.google_storage_bucket_object.dvdrental_restore
  ]
}
