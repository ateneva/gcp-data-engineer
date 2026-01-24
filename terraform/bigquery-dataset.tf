
resource "google_bigquery_dataset" "the-data-challenge" {
  dataset_id                  = "the_data_challenge"
  friendly_name               = "the-data-challenge"
  description                 = "This dataset stores the data-engineering challenge"
  location                    = "EU"
  default_table_expiration_ms = 3600000
  labels = {
    env = "default"
  }
}