
// 4. Create BigQuery dataset for the Sakila database
resource "google_bigquery_dataset" "sakila_bq" {
  dataset_id  = "sakila_streaming"
  location    = "europe-west1"
  description = "This dataset stores streaming data from sakila mysql database"
}
