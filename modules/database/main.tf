# 1. Reserving a private IP range for Google's services (requirement for private Cloud SQL)
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.db_name}-private-ip"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_id
}

# 2. Creating a VPC Peering connection with Google's network
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# 3. Cloud SQL instance (PostgreSQL)
resource "google_sql_database_instance" "instance" {
  name             = "${var.db_name}-instance"
  region           = var.region
  database_version = "POSTGRES_14"
  project          = var.project_id

  # NOTE: We intentionally disable this for the task to allow 'terraform destroy' to work smoothly and remove the database for the recruiter. In production, this should always be true
  deletion_protection = false 

  # Wait for the VPC peering connection to be established before creating the SQL instance to avoid dependency issues.
  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = var.db_tier
    
    availability_type = "REGIONAL" 

    # Force private IP, no public IP assigned to the instance. Full security.
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }
  }
}

# 4. Database and user creation
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.instance.name
  project  = var.project_id
}

resource "google_sql_user" "users" {
  name     = var.db_user
  instance = google_sql_database_instance.instance.name
  password = var.db_password
  project  = var.project_id
}
