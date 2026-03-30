variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region for the subnet and NAT"
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "inpost-app-vpc"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "inpost-app-subnet"
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}
