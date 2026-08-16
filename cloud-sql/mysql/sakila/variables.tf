variable "gcp_project_id" {
  description = "Your GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region where resources will be created"
  type        = string
  default     = "europe-west1"
}