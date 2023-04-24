terraform {
  backend "gcs" {}

  required_providers {
    google = {
      version = "~> 4.15.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

