
resource "google_iam_workload_identity_pool" "github_gcp_pool" {
  project                   = "data-geeking-gcp"
  workload_identity_pool_id = "github-gcp-pool"
  display_name              = "GitHub Pool"
  description               = "Workload Identity Pool for GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github_gcp_provider" {
  project                            = "data-geeking-gcp"
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_gcp_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-gcp-provider"
  display_name                       = "GitHub GCP Provider"
  description                        = "Workload Identity Pool Provider for GitHub Actions"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
  attribute_condition = "assertion.repository == 'ateneva/gcp-data-engineer'"
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "github_gcp_actions" {
  project      = "data-geeking-gcp"
  account_id   = "github-actions-gcp-sa"
  display_name = "GitHub Actions GCP Service Account"
}

resource "google_service_account_iam_member" "workload_identity_user_gcp" {
  service_account_id = google_service_account.github_gcp_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_gcp_pool.name}/attribute.repository/ateneva/gcp-data-engineer"
}

output "gcp_identity_provider_name" {
  value = google_iam_workload_identity_pool_provider.github_gcp_provider.name
  description = "The full identifier of the Workload Identity Pool Provider"
}

output "gcp_service_account_email" {
  value = google_service_account.github_gcp_actions.email
  description = "The email of the service account created for GitHub Actions"
}
