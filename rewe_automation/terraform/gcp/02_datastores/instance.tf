resource "google_compute_instance" "datastore" {
  name         = module.naming.id
  description  = "Datastore host for distributed operator based"
  machine_type = var.instance_type
  zone         = var.zone

  labels = module.naming.tags

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = "200"
    }
  }

  network_interface {
    network    = data.terraform_remote_state.networking.outputs.network_link
    subnetwork = data.terraform_remote_state.networking.outputs.subnetwork_link
  }

  service_account {
    email  = google_service_account.registry.email
    scopes = ["cloud-platform"]
  }
}
