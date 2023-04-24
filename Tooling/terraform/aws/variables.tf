variable "profile" {
  type    = string
  default = "support-sre"
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "tagprefix" {
  type = string
  default = "support_sre"
}

variable "cluster_version" {
  type = string
  default = "1.20"
}