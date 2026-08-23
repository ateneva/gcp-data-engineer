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
resource "google_sql_database_instance" "mysql_airport_instance" {
  name             = "mysql-airport-db-${random_id.db_suffix.hex}"
  database_version = "MYSQL_8_4"
  region           = var.region

  # Set to false so you can tear down the test environment with `terraform destroy`
  deletion_protection = false

  settings {
    # Smallest tier available (shared vCPU, 0.6 GB RAM) suitable for testing/development
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true

      # Add authorized networks if you need direct external access, or rely on Cloud SQL Proxy
      # authorized_networks {
      #   name  = "my-ip"
      #   value = "YOUR_PUBLIC_IP/32"
      # }
    }

    backup_configuration {
      enabled    = true
      start_time = "04:00"
    }
  }
}

# 2. Database Creation
resource "google_sql_database" "airport_db" {
  name     = "airport_db"
  instance = google_sql_database_instance.mysql_airport_instance.name
}

# 3. Random Root Password Generation
resource "random_password" "airport_db_password" {
  length  = 16
  special = true
}

# 4. Database User
resource "google_sql_user" "airport_db_user" {
  name     = "airport_user"
  instance = google_sql_database_instance.mysql_airport_instance.name
  password = random_password.airport_db_password.result
}