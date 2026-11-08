
// 1. Create or Import (if already exist) Service accounts and IAM roles for Datastream

import {
  to = google_service_account.datastream_sa
  id = "projects/data-geeking-gcp/serviceAccounts/datastream-sa@data-geeking-gcp.iam.gserviceaccount.com"
}

resource "google_service_account" "datastream_sa" {
  account_id   = "datastream-sa"
  display_name = "Datastream service account"
}

import {
  to = google_project_iam_member.datastream_bq_writer
  id = "data-geeking-gcp roles/bigquery.dataEditor serviceAccount:datastream-sa@data-geeking-gcp.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "datastream_bq_writer" {
  project = "data-geeking-gcp"
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.datastream_sa.email}"
}

import {
  to = google_project_iam_member.datastream_admin
  id = "data-geeking-gcp roles/datastream.admin serviceAccount:datastream-sa@data-geeking-gcp.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "datastream_admin" {
  project = "data-geeking-gcp"
  role    = "roles/datastream.admin"
  member  = "serviceAccount:${google_service_account.datastream_sa.email}"
}
