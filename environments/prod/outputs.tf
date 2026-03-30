output "app_url" {
  description = "Public application's IP address (Load Balancer)"
  value       = module.compute.load_balancer_ip
}

output "database_private_ip" {
  value = module.database.db_private_ip
}
