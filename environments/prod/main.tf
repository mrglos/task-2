provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Network
module "networking" {
  source     = "../../modules/networking"
  project_id = var.project_id
  region     = var.region
}

# 2. Database - requires network for Private IP
module "database" {
  source      = "../../modules/database"
  project_id  = var.project_id
  region      = var.region
  network_id  = module.networking.network_id
  db_password = var.db_password
  db_tier     = "db-custom-2-7680" # 2 vCPU, 7.5 GB RAM
}

# 3. Compute - application (Nginx, MIG, Load Balancer)
module "compute" {
  source     = "../../modules/compute"
  project_id = var.project_id
  region     = var.region
  network_id = module.networking.network_id
  subnet_id  = module.networking.subnet_id
  machine_type = "e2-standard-2"
}

# 4. Storage
module "storage" {
  source      = "../../modules/storage"
  project_id  = var.project_id
  region      = var.region
  bucket_name = "${var.project_id}-static-assets"
}
