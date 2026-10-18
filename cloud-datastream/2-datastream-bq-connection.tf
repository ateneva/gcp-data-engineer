
// 2. Create Datastream connection profile for BigQuery destination
resource "google_datastream_connection_profile" "bq_cp" {
  connection_profile_id = "datastream-bigquery"
  display_name          = "datastream-bigquery"
  location              = "eu-west1"
  bigquery_profile {}
}
