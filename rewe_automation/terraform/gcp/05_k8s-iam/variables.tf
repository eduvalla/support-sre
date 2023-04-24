variable "environment" {
  description = "The name of the environment"
  type        = string
}

variable "project" {
  description = "The GCP project"
  type        = string
}

variable "region" {
  description = "The GCP region to create resources in"
  type        = string
}

variable "zone" {
  description = "The GCP zone to create resources in"
  type        = string
}

variable "state_bucket" {
  description = "The name of the bucket for storing Terraform state"
  type        = string
}
