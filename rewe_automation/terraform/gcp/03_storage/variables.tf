variable "environment" {
  description = "The name of the environment"
  type = string
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

variable "raw_spans_retention_days" {
  description = "The number of days to keep raw span data in the bucket"
  type    = number
  default = 7
}
