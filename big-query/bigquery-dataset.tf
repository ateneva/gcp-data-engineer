
resource "google_bigquery_dataset" "eu-data-challenge" {
  dataset_id                  = "eu_data_challenge"
  friendly_name               = "eu-data-challenge"
  description                 = "This dataset stores the data-engineering challenge"
  location                    = "EU"
  default_table_expiration_ms = 1296000000 # 15 days
  labels = {
    env = "default"
  }
}

resource "google_bigquery_dataset" "sakilla" {
  dataset_id                  = "sakilla"
  friendly_name               = "sakilla"
  description                 = "This dataset stores a copy of the sakila database that was datastreamed"
  location                    = "europe-west1"
}

resource "google_bigquery_dataset" "dvd_rental" {
  dataset_id                  = "dvd_rental"
  friendly_name               = "dvd_rental"
  description                 = "This dataset stores a copy of the dvd_rental database that was datastreamed"
  location                    = "europe-west1"
}

resource "google_bigquery_dataset" "advetureworks" {
  dataset_id                  = "advetureworks"
  friendly_name               = "advetureworks"
  description                 = "This dataset stores a copy of the advetureworks database that was datastreamed"
  location                    = "europe-west1"
}