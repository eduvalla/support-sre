terraform {
  backend "gcs" {}

  required_providers {
    local = {
      version = "~> 2.1.0"
    }
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

