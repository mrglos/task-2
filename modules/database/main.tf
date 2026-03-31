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

# 3. Cloud SQL instance (PostgreSQL) with IAM auth
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

    # Enable IAM database authentication for secure access without passwords.
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  }
}

# 4. Database and user (based on IAM) creation
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.instance.name
  project  = var.project_id
}

resource "google_sql_user" "iam_user" {
  name     = replace(var.app_service_account_email, ".gserviceaccount.com", "")
  instance = google_sql_database_instance.instance.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
  project  = var.project_id
}

# 5. Granting the service account the necessary role to connect to the database
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${var.app_service_account_email}"
}

resource "google_project_iam_member" "cloudsql_instance_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${var.app_service_account_email}"
}
