output "db_instance_name" {
  value = google_sql_database_instance.instance.name
}

output "db_private_ip" {
  description = "The private IP address of the database"
  value       = google_sql_database_instance.instance.private_ip_address
}
