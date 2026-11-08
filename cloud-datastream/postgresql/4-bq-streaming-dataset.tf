
// 4. Create BigQuery dataset for the dvdrental database
resource "google_bigquery_dataset" "dvdrental_bq" {
  dataset_id  = "dvdrental_streaming"
  location    = "europe-west1"
  description = "This dataset stores streaming data from sakila mysql database"
}