
// 3. Create Service accounts and IAM roles for Datastream
resource "google_service_account" "datastream_sa" {
  account_id   = "datastream-sa"
  display_name = "Datastream service account"
}

resource "google_project_iam_member" "datastream_bq_writer" {
  project = "data-geeking-gcp"
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.datastream_sa.email}"
}

resource "google_project_iam_member" "datastream_admin" {
  project = "data-geeking-gcp"
  role    = "roles/datastream.admin"
  member  = "serviceAccount:${google_service_account.datastream_sa.email}"
}
