variable "environment" {
  description = "The name of the environment"
  type = string
}

variable "project" {
  description = "The GCP project"
  type = string
}

variable "region" {
  description = "The GCP region to create resources in"
  type = string
}

variable "zone" {
  description = "The GCP zone to create resources in"
  type = string
}

variable "state_bucket" {
  description = "The name of the bucket for storing Terraform state"
  type = string
}

variable "installer_version" {
  description = "The version of the Docker-based installer. Use '*' for the latest version"
  type    = string
  default = "*"
}

variable "rpm_repo_url" {
  description = "The URL of the RPM repository"
  type    = string
  default = "https://instana-onprem-installer-internal.s3.amazonaws.com"
}

variable "agent_key_db" {
  description = "The agent key for the data store host"
  type = string
}

variable "download_key_db" {
  description = "The download key for the data store host"
  type        = string
}

variable "base_domain" {
  description = "The base domain"
  type = string
}

variable "instana_registry" {
  description = "The Docker registry to pull images from"
  default = "containers.instana.io"
}

variable "instance_type" {
  description = "The GCP machine type"
  type = string
}