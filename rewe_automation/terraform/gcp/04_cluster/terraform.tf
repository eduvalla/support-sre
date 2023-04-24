terraform {
  backend "gcs" {}

  required_providers {
    google-beta = {
      version = "~> 4.15.0"
    }
  }
}

provider "google-beta" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
