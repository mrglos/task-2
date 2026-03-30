variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region for the instances"
  type        = string
}

variable "network_id" {
  description = "The VPC network ID"
  type        = string
}

variable "subnet_id" {
  description = "The Subnet ID"
  type        = string
}

variable "app_name" {
  description = "Application name used for naming resources"
  type        = string
  default     = "inpost-web"
}

variable "machine_type" {
  description = "The machine type for the web instances"
  type        = string
  default     = "e2-micro"
}
