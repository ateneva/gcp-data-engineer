# 1. Fetch the Cloud Storage bucket and BAK object
data "google_storage_bucket_object" "adventureworks_bak" {
  name   = "gcp/databases/AdventureWorksDW2017.bak"
  bucket = "data-engineer-in-training"
}

# 2. Grant the Cloud SQL service account access to read from the bucket
resource "google_storage_bucket_iam_member" "sql_import_grant" {
  bucket = "data-engineer-in-training"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_sql_database_instance.sqlserver_instance.service_account_email_address}"
}

# 3. Execute the BAK import command
# For SQL Server, we use 'import bak'
resource "null_resource" "db_bak_import" {
  triggers = {
    bak_file_hash = data.google_storage_bucket_object.adventureworks_bak.md5hash
    instance_id   = google_sql_database_instance.sqlserver_instance.id
  }

  provisioner "local-exec" {
    command = <<EOT
      gcloud sql import bak ${google_sql_database_instance.sqlserver_instance.name} \
        gs://${data.google_storage_bucket_object.adventureworks_bak.bucket}/${data.google_storage_bucket_object.adventureworks_bak.name} \
        --database=AdventureWorksDW2017 \
        --project=${var.gcp_project_id} \
        --quiet
    EOT
  }

  depends_on = [
    google_sql_database_instance.sqlserver_instance,
    google_storage_bucket_iam_member.sql_import_grant
  ]
}
