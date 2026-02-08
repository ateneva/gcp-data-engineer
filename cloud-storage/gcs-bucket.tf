resource "google_storage_bucket" "eu-data-challenge" {
  name          = "eu-data-challenge"
  location      = "EU"
  storage_class = "NEARLINE"
  public_access_prevention = "enforced"
  uniform_bucket_level_access = true
  force_destroy = true
}

module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.0"
  project_id    = "data-geeking-gcp"
  prefix        = "storage-bq"
  names         = ["upload-data"]
  project_roles = [
    "data-geeking-gcp=>roles/storage.admin",
    "data-geeking-gcp=>roles/bigquery.admin"
  ]
  generate_keys = true
}