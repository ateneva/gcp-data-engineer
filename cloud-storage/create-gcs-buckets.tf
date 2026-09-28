resource "google_storage_bucket" "eu-data-challenge" {
  name          = "eu-data-challenge"
  location      = "EU"
  storage_class = "STANDARD"
  public_access_prevention = "enforced"
  uniform_bucket_level_access = true
  force_destroy = false

  retention_policy {
    retention_period = 2592000
  }
}

resource "google_storage_bucket" "eu-data-books" {
  name          = "eu-data-books"
  location      = "europe-west1"
  storage_class = "ARCHIVE"
  public_access_prevention = "enforced"
  uniform_bucket_level_access = true
  force_destroy = false
}

resource "google_storage_bucket" "eu-languages-books" {
  name          = "eu-languages-books"
  location      = "europe-west1"
  storage_class = "ARCHIVE"
  public_access_prevention = "enforced"
  uniform_bucket_level_access = true
  force_destroy = false
}

resource "google_storage_bucket" "eu-marketing-books" {
  name          = "eu-marketing-books"
  location      = "europe-west1"
  storage_class = "ARCHIVE"
  public_access_prevention = "enforced"
  uniform_bucket_level_access = true
  force_destroy = false
}

resource "google_storage_bucket" "eu-business-books" {
  name          = "eu-business-books"
  location      = "europe-west1"
  storage_class = "ARCHIVE"
  public_access_prevention = "enforced"
  uniform_bucket_level_access = true
  force_destroy = false
}