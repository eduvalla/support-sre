variable "project_id" {
  type        = string
  default     = ""
  description = "GCP project id"

  validation {
    condition     = contains(["instana-production", "instana-internal"], var.project_id)
    error_message = "The project_id must be one of [\"instana-production\", \"instana-internal\"]."
  }
}

variable "instana_region" {
  type        = string
  default     = ""
  description = "The instana_region. E.g. green"

  validation {
    condition = contains(["green", "orange", "coral", "instana-infra"], var.instana_region)
    error_message = "The instana_region alias must be one of [\"green\", \"orange\", \"coral\", \"instana-infra\"]."
  }
}

variable "zone" {
  type        = string
  default     = ""
  description = "The zone could build instance belongs to"

  validation {
    condition = length(regexall("europe-west1|us-east1-.*|us-west1-.*", var.zone)) > 0
    error_message = "The zone value must be starting with one of [\"europe-west1\", \"us-east1\", \"us-west1\"]."
  }
}

variable "source_image" {
  type        = string
  default     = "ubuntu-minimal-1804-bionic-v20211119"
  description = "The id of the source image to use."

  validation {
    condition     = length(var.source_image) > 7 && substr(var.source_image, 0, 7) == "ubuntu-"
    error_message = "The source_image value must be a valid image id, starting with \"ubuntu-\"."
  }
}

variable "network" {
  type        = string
  default     = ""
  description = "The network to use."

  validation {
    condition     = length(regexall("instana-.*", var.network)) > 0
    error_message = "The network value must be a valid network name, starting with \"instana-\"."
  }
}

variable "subnetwork" {
  type        = string
  default     = ""
  description = "The subnetwork to use."

  validation {
    condition     = length(regexall("instana-.*", var.subnetwork)) > 0
    error_message = "The subnetwork value must be a valid subnetwork name, starting with \"instana-\"."
  }
}

variable "disk_size" {
  type        = string
  default     = "20"
  description = "Disk size"

  validation {
    condition     = parseint(var.disk_size, 10) > 0
    error_message = "The disk_size must be more than 0."
  }
}

variable "apt_region" {
  type        = string
  default     = ""
  description = "The package repository region"

  validation {
    condition = contains(["eu-west-1", "us-west-2", "us-west1"], var.apt_region)
    error_message = "The apt_region must be one of [\"eu-west-1\", \"us-west-2\", \"us-west1\"]."
  }
}

variable "apt_state" {
  type        = string
  default     = ""
  description = "The distict string in package repository location"

  validation {
    condition     = contains(["eu", "us"], var.apt_state)
    error_message = "The apt_state must be one of [\"eu\", \"us\"]."
  }
}

variable "purpose" {
  type        = string
  default     = "fleet"
  description = "The purpose label value"

  validation {
    condition     = length(var.purpose) > 0
    error_message = "The purpose value must not be blank."
  }
}
