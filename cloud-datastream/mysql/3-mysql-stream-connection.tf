
locals {
  mysql_connections = {
    for file in fileset(path.module, "connections/*.yaml") :
    trimsuffix(basename(file), ".yaml") => yamldecode(file("${path.module}/${file}"))
  }
}

resource "google_datastream_connection_profile" "mysql_cp" {
  for_each = local.mysql_connections

  connection_profile_id = each.value.connection_profile_id
  display_name          = each.value.display_name
  location              = each.value.location

  mysql_profile {
    hostname = each.value.hostname
    port     = each.value.port
    username = each.value.username
    password = var.mysql_connection_credentials[each.key].password
  }
}
