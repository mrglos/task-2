variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  default = "europe-central2"
}

variable "db_password" {
  description = "Database password (best provide via TF_VAR or Secret Manager)"
  type        = string
  sensitive   = true
}
