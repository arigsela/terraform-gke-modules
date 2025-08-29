output "cluster_id" {
  description = "The ID of the cluster"
  value       = google_container_cluster.primary.id
}

output "name" {
  description = "The name of the cluster"
  value       = google_container_cluster.primary.name
}

output "location" {
  description = "The location of the cluster"
  value       = google_container_cluster.primary.location
}

output "endpoint" {
  description = "The IP address of the cluster master"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "master_version" {
  description = "The current version of the master in the cluster"
  value       = google_container_cluster.primary.master_version
}

output "ca_certificate" {
  description = "The cluster CA certificate (base64 encoded)"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "network" {
  description = "The name of the Google Compute Engine network to which the cluster is connected"
  value       = google_container_cluster.primary.network
}

output "subnetwork" {
  description = "The name of the Google Compute Engine subnetwork in which the cluster's instances are launched"
  value       = google_container_cluster.primary.subnetwork
}

output "cluster_secondary_range_name" {
  description = "The name of the secondary range used for pods"
  value       = google_container_cluster.primary.ip_allocation_policy[0].cluster_secondary_range_name
}

output "services_secondary_range_name" {
  description = "The name of the secondary range used for services"
  value       = google_container_cluster.primary.ip_allocation_policy[0].services_secondary_range_name
}