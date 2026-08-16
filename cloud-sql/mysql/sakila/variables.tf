variable "gcp_project_id" {
  description = "Your GCP Project ID"
  type        = string
  default     = "data-geeking-gcp"
}

variable "region" {
  description = "GCP region where resources will be created"
  type        = string
  default     = "europe-west1"
}