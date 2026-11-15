variable "mysql_connection_credentials" {
  description = "MySQL usernames and passwords, keyed by connection YAML filename without the extension"
  type = map(object({
    password = string
  }))
  sensitive = true
}
