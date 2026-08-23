terraform {
  required_version = ">= 1.0"
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

# Generate a random suffix for the instance name
resource "random_id" "db_suffix" {
  byte_length = 4
}

# 1. Cloud SQL Instance Configuration (PostgreSQL)
resource "google_sql_database_instance" "postgres_dvdrental_instance" {
  name             = "postgres-dvdrental-db-${random_id.db_suffix.hex}"
  database_version = "POSTGRES_15"
  region           = var.region

  deletion_protection = false

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true
    }

    backup_configuration {
      enabled    = true
      start_time = "04:00"
    }
  }
}

# 2. Database Creation
resource "google_sql_database" "dvdrental_db" {
  name     = "dvdrental"
  instance = google_sql_database_instance.postgres_dvdrental_instance.name
}

# 3. Random Password Generation
resource "random_password" "dvdrental_db_password" {
  length  = 16
  special = true
}

# 4. Database User
resource "google_sql_user" "dvdrental_db_user" {
  name     = "dvdrental_user"
  instance = google_sql_database_instance.postgres_dvdrental_instance.name
  password = random_password.dvdrental_db_password.result
}
