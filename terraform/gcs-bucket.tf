resource "google_storage_bucket" "eu-data-challenge" {
  name          = "eu-data-challenge"
  location      = "EU"
  storage_class = "NEARLINE"
  public_access_prevention = "enforced"
  uniform_bucket_level_access = true
  force_destroy = true
}
