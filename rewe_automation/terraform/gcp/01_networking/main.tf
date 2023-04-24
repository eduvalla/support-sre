module "naming" {
  source      = "../_modules/naming"
  name        = "networking"
  environment = var.environment
}

locals {
  cluster_range = "192.168.64.0/22"
}

resource "google_compute_network" "network" {
  name                    = module.naming.id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = module.naming.id
  network       = google_compute_network.network.self_link
  region        = var.region
  ip_cidr_range = "10.164.0.0/20"

  // Docs on alias IPs:
  // cloud.google.com/vpc/docs/alias-ip
  // cloud.google.com/kubernetes-engine/docs/how-to/alias-ips

  secondary_ip_range {
    # IP range for Kubernetes services
    range_name    = "services-range"
    ip_cidr_range = "192.168.1.0/24"
  }

  secondary_ip_range {
    // IP range for Kubernetes pods
    range_name    = "cluster-range"
    ip_cidr_range = local.cluster_range
  }
}

// Allow all tcp services inside the vpc
resource "google_compute_firewall" "db" {
  name    = "${module.naming.id}-db"
  network = google_compute_network.network.self_link

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65534"]
  }
  source_ranges = [local.cluster_range]
}

resource "google_compute_firewall" "web" {
  name    = "${module.naming.id}-web"
  network = google_compute_network.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
}

// GCP IAP range for SSH access via gcloud CLI
resource "google_compute_firewall" "ssh" {
  name    = "${module.naming.id}-ssh"
  network = google_compute_network.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}

// Cloud Router to enable internet access without public IP
resource "google_compute_router" "router" {
  name    = module.naming.id
  network = google_compute_network.network.self_link
}

// Cloud NAT config resource
resource "google_compute_router_nat" "nat" {
  name                               = module.naming.id
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
