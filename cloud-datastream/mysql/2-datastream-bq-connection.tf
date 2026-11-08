
// 2. Create or Import (if already exists) Datastream connection profile for BigQuery destination

import {
  to = google_datastream_connection_profile.bq_cp
  id = "projects/data-geeking-gcp/locations/europe-west1/connectionProfiles/datastream-bigquery"
}

resource "google_datastream_connection_profile" "bq_cp" {
  connection_profile_id = "datastream-bigquery"
  display_name          = "datastream-bigquery"
  location              = "europe-west1"
  bigquery_profile {}
}
