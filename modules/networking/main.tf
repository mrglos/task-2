# 1. We create a custom VPC (disable auto-creation of subnetworks)
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# 2. We create a dedicated subnet in the chosen region
resource "google_compute_subnetwork" "subnet" {
  name                     = var.subnet_name
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr
  # Allow instances in this subnet to access Google APIs without needing a public IP address (required for private Cloud SQL)
  private_ip_google_access = true
}

# 3. Cloud Router (required for Cloud NAT)
resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.id
}

# 4. Cloud NAT (allows instances without public IP to access the Internet)
resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-nat"
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# 5. Firewall: Allow Health Checks from Google Load Balancer
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.network_name}-allow-hc"
  project = var.project_id
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  # These IP ranges are the official Google Load Balancer health check servers
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["web-app"]
}

# 6. Firewall: Allow secure SSH access through IAP (Identity-Aware Proxy)
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.network_name}-allow-iap-ssh"
  project = var.project_id
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Official IP range for Google IAP
  source_ranges = ["35.235.240.0/20"]
}
