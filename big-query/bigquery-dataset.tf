
resource "google_bigquery_dataset" "eu-data-challenge" {
  dataset_id                  = "eu_data_challenge"
  friendly_name               = "eu-data-challenge"
  description                 = "This dataset stores the data-engineering challenge"
  location                    = "EU"
  default_table_expiration_ms = 1296000000  # 15 days
  labels = {
    env = "default"
  }
}