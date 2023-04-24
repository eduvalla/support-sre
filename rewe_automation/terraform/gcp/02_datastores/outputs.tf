output "datastores_ip" {
  description = "The IP address of the datastores host"
  value = google_compute_instance.datastore.network_interface.0.network_ip
}
