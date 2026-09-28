terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
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

# 1. Cloud SQL Instance Configuration (SQL Server 2017)
resource "google_sql_database_instance" "sqlserver_instance" {
  name             = "sqlserver-adventureworks-${random_id.db_suffix.hex}"
  database_version = "SQLSERVER_2017_STANDARD"
  region           = var.region
  root_password    = random_password.sa_password.result

  deletion_protection = false

  settings {
    # SQL Server requires a higher tier than MySQL/PostgreSQL micro instances
    tier = "db-custom-2-3840"

    ip_configuration {
      ipv4_enabled = true

      # Datastream Public IPs for europe-west1
      authorized_networks {
        name  = "datastream-1"
        value = "104.199.6.64/32"
      }
      authorized_networks {
        name  = "datastream-2"
        value = "34.78.213.130/32"
      }
      authorized_networks {
        name  = "datastream-3"
        value = "35.205.33.30/32"
      }
      authorized_networks {
        name  = "datastream-4"
        value = "35.205.125.111/32"
      }
      authorized_networks {
        name  = "datastream-5"
        value = "35.187.27.174/32"
      }
    }

    backup_configuration {
      enabled    = true
      start_time = "04:00"
    }
  }
}

# 2. Random SA Password Generation
resource "random_password" "sa_password" {
  length  = 16
  special = true
}

