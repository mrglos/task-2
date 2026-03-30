output "load_balancer_ip" {
  description = "The public IP address of the Global Load Balancer"
  value       = google_compute_global_forwarding_rule.web_forwarding_rule.ip_address
}

output "service_account_email" {
  description = "The email of the compute service account"
  value       = google_service_account.web_sa.email
}
