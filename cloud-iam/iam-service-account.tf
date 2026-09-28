module "service_accounts" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 4.0"
  project_id = "data-geeking-gcp"
  prefix     = "storage-bq"
  names      = ["upload-data"]
  project_roles = [
    "data-geeking-gcp=>roles/storage.admin",
    "data-geeking-gcp=>roles/bigquery.admin"
  ]
  generate_keys = true
}
