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

# Generate a random suffix for the instance name (Cloud SQL names cannot be reused immediately after deletion)
resource "random_id" "db_suffix" {
  byte_length = 4
}

# 1. Cloud SQL Instance Configuration
resource "google_sql_database_instance" "mysql_instance" {
  name             = "mysql-sakila-db-${random_id.db_suffix.hex}"
  database_version = "MYSQL_8_4"
  region           = var.region

  # Set to false so you can tear down the test environment with `terraform destroy`
  deletion_protection = false

  settings {
    # Smallest tier available (shared vCPU, 0.6 GB RAM) suitable for testing/development
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true

      # Authorize Datastream public IPs for europe-west1
      authorized_networks {
        name  = "datastream-1"
        value = "34.76.23.102/32"
      }
      authorized_networks {
        name  = "datastream-2"
        value = "34.140.90.170/32"
      }
      authorized_networks {
        name  = "datastream-3"
        value = "34.140.108.199/32"
      }
      authorized_networks {
        name  = "datastream-4"
        value = "34.140.237.112/32"
      }
      authorized_networks {
        name  = "datastream-5"
        value = "34.140.173.91/32"
      }
    }

    backup_configuration {
      enabled            = true
      binary_log_enabled = true     # binary logs are needed for the stream to capture any CDC changes
      start_time         = "04:00"
    }
  }
}

# 2. Database Creation
resource "google_sql_database" "sakilla_db" {
  name     = "sakilla_db"
  instance = google_sql_database_instance.mysql_instance.name
}

# 3. Random Root Password Generation
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# 4. Database User
resource "google_sql_user" "db_user" {
  name     = "sakilla_user"
  instance = google_sql_database_instance.mysql_instance.name
  password = random_password.db_password.result
}