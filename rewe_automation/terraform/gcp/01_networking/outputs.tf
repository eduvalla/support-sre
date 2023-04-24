output "network_link" {
  description = "The network's self-link"
  value = google_compute_network.network.self_link
}

output "subnetwork_link" {
  description = "The subnetwork's self-link"
  value = google_compute_subnetwork.subnetwork.self_link
}

