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

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "inpost-admin"
}

variable "db_tier" {
  description = "The machine type for the database instance"
  type        = string
  default     = "db-f1-micro"
}
