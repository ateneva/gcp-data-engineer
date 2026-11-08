variable "postgresql_hostname" {
  description = "host address of the postgresql database"
  type        = string
}

variable "postgresql_username" {
  description = "user for connecting to the postgresql database"
  type        = string
}

variable "postgresql_password" {
  description = "password for connecting to the postgresql database"
  type        = string
}

variable "postgresql_db" {
  description = "name of the postgresql database"
  type        = string
}