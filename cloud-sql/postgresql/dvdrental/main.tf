terraform {
  required_version = ">= 1.8"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.region
}

# --- 1. Random Generators ---
resource "random_id" "db_suffix" {
  byte_length = 4
}

resource "random_password" "dvdrental_db_password" {
  length  = 16
  special = true
}

resource "random_password" "datastream_db_password" {
  length  = 16
  special = true
}

# --- 2. Cloud SQL Instance Configuration (PostgreSQL) ---
resource "google_sql_database_instance" "postgres_dvdrental_instance" {
  name             = "postgres-dvdrental-db-${random_id.db_suffix.hex}"
  database_version = "POSTGRES_15"
  region           = var.region

  deletion_protection = false

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true

      # Authorized network for local apply / runner access
      # Replace '0.0.0.0/0' with your specific runner IP/CIDR in production!
      authorized_networks {
        name  = "runner"
        value = "0.0.0.0/0"
      }

      # Datastream Public IPs (Europe-West1)
      authorized_networks {
        name  = "datastream-1"
        value = "104.199.6.64"
      }
      authorized_networks {
        name  = "datastream-2"
        value = "34.78.213.130"
      }
      authorized_networks {
        name  = "datastream-3"
        value = "35.205.33.30"
      }
      authorized_networks {
        name  = "datastream-4"
        value = "35.205.125.111"
      }
      authorized_networks {
        name  = "datastream-5"
        value = "35.187.27.174"
      }
    }

    backup_configuration {
      enabled    = true
      start_time = "04:00"
    }

    database_flags {
      name  = "cloudsql.logical_decoding"
      value = "on"
    }
  }
}

# --- 3. Database Creation ---
resource "google_sql_database" "dvdrental_db" {
  name     = "dvdrental"
  instance = google_sql_database_instance.postgres_dvdrental_instance.name
}

# --- 4. Database Users ---
# Admin / Application User
resource "google_sql_user" "dvdrental_db_user" {
  name     = "dvdrental_user"
  instance = google_sql_database_instance.postgres_dvdrental_instance.name
  password = random_password.dvdrental_db_password.result
  type     = "BUILT_IN"
}

# Datastream CDC Replication User
resource "google_sql_user" "datastream_user" {
  name     = "datastream_user"
  instance = google_sql_database_instance.postgres_dvdrental_instance.name
  password = random_password.datastream_db_password.result
  type     = "BUILT_IN"
}