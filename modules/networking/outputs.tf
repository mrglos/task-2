output "network_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.vpc.id
}

output "network_self_link" {
  description = "The URI of the VPC"
  value       = google_compute_network.vpc.self_link
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_self_link" {
  description = "The URI of the subnet"
  value       = google_compute_subnetwork.subnet.self_link
}
