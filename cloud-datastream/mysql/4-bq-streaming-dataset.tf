
// 4. Create or Import (if already exists) BigQuery dataset for the Sakila database

import {
  to = google_bigquery_dataset.sakila_bq
  id = "projects/data-geeking-gcp/datasets/sakila_streaming"
}

resource "google_bigquery_dataset" "sakila_bq" {
  dataset_id  = "sakila_streaming"
  location    = "europe-west1"
  description = "This dataset stores streaming data from sakila mysql database"
}
