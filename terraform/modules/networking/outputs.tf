output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "network_self_link" {
  description = "The self link of the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "subnets" {
  description = "Map of subnet names to subnet objects"
  value = { for k, v in google_compute_subnetwork.subnet : k => {
    name        = v.name
    id          = v.id
    self_link   = v.self_link
    ip_cidr_range = v.ip_cidr_range
    region      = v.region
    secondary_ip_range = v.secondary_ip_range
  }}
}

output "subnets_names" {
  description = "List of subnet names"
  value       = [for subnet in google_compute_subnetwork.subnet : subnet.name]
}

output "subnets_ips" {
  description = "List of subnet IP ranges"
  value       = [for subnet in google_compute_subnetwork.subnet : subnet.ip_cidr_range]
}

output "router_name" {
  description = "Name of the router"
  value       = google_compute_router.router.name
}

output "nat_name" {
  description = "Name of the NAT gateway"
  value       = google_compute_router_nat.nat.name
}