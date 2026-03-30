variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region for the bucket"
  type        = string
}

variable "bucket_name" {
  description = "Global unique name of the bucket"
  type        = string
}
