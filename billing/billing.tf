
resource "google_bigquery_dataset" "billing" {
  dataset_id                  = "billing"
  friendly_name               = "Billing"
  description                 = "This dataset stores the billing data"
  location                    = "europe-west1"
}
