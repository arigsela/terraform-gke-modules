variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "gke-vpc"
}

variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    subnet_name   = string
    subnet_ip     = string
    subnet_region = string
  }))
  default = [{
    subnet_name   = "gke-subnet"
    subnet_ip     = "10.0.1.0/24"
    subnet_region = "us-central1"
  }]
}

variable "secondary_ranges" {
  description = "Secondary ranges for subnets"
  type = map(list(object({
    range_name    = string
    ip_cidr_range = string
  })))
  default = {
    "gke-subnet" = [
      {
        range_name    = "gke-pods"
        ip_cidr_range = "10.1.0.0/16"
      },
      {
        range_name    = "gke-services"
        ip_cidr_range = "10.2.0.0/16"
      }
    ]
  }
}