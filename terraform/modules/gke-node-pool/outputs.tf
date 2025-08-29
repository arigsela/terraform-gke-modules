output "name" {
  description = "The name of the node pool"
  value       = google_container_node_pool.pool.name
}

output "id" {
  description = "The ID of the node pool"
  value       = google_container_node_pool.pool.id
}

output "instance_group_urls" {
  description = "List of instance group URLs of the node pool"
  value       = google_container_node_pool.pool.instance_group_urls
}

output "managed_instance_group_urls" {
  description = "List of managed instance group URLs of the node pool"
  value       = google_container_node_pool.pool.managed_instance_group_urls
}

output "version" {
  description = "The Kubernetes version on the nodes"
  value       = google_container_node_pool.pool.version
}