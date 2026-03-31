variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region for the database"
  type        = string
}

variable "network_id" {
  description = "The VPC network ID for private connection"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "inpost-db"
}

variable "db_tier" {
  description = "The machine type for the database instance"
  type        = string
  default     = "db-f1-micro"
}

variable "app_service_account_email" {
  description = "The email of the compute service account that will connect to the DB"
  type        = string
}
