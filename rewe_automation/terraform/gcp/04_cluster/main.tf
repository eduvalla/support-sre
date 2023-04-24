module "naming" {
  source      = "../_modules/naming"
  name        = "gke"
  environment = var.environment
}

resource "google_container_cluster" "cluster" {
  provider = google-beta

  name               = module.naming.id
  initial_node_count = var.node_count
  description        = "GKE cluster for Instana operator setups"
  network            = data.terraform_remote_state.networking.outputs.network_link
  subnetwork         = data.terraform_remote_state.networking.outputs.subnetwork_link
  min_master_version = var.kubernetes_version
  location           = var.zone
  resource_labels    = module.naming.tags

  cluster_autoscaling {
    enabled             = true
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
    resource_limits {
      resource_type = "cpu"
      minimum       = 24
      maximum       = 40
    }
    resource_limits {
      resource_type = "memory"
      minimum       = 90
      maximum       = 150
    }
  }

  addons_config {
    network_policy_config {
      disabled = "false"
    }

    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "00:00"
    }
  }

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "cluster-range"
    services_secondary_range_name = "services-range"
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS",
    ]
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS",
    ]
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]

    machine_type = "e2-standard-8"
  }

  lifecycle {
    ignore_changes = [node_pool, initial_node_count]
  }
}

