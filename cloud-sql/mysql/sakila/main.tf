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
      enabled            = true
      binary_log_enabled = true # binary logs are needed for the stream to capture any CDC changes
      start_time         = "04:00"
    }

    database_flags {
      name  = "log_bin_trust_function_creators"
      value = "on"
    }
  }
}

# 2. Database Creation
resource "google_sql_database" "sakilla_db" {
  name     = "sakila"
  instance = google_sql_database_instance.mysql_instance.name
}

# 3. Random Root Password Generation
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# 4. Database User (allows remote connections e.g. Datastream and localhost for Cloud SQL Studio)
resource "google_sql_user" "db_user" {
  name     = "sakilla_user"
  instance = google_sql_database_instance.mysql_instance.name
  password = random_password.db_password.result
  host     = "%"
}

resource "google_sql_user" "db_user_localhost" {
  name     = "sakilla_user"
  instance = google_sql_database_instance.mysql_instance.name
  password = random_password.db_password.result
  host     = "localhost"
}