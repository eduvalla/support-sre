variable "region" {
  type = string
  default = ""

  validation {
    condition = contains(["eu-west-1", "us-west-2"], var.region)
    error_message = "The region must be eu-west-1 or us-west-2."
  }
}

variable "vpc" {
  type = string
  default = ""

  validation {
    condition = length(var.vpc) > 4 && substr(var.vpc, 0, 4) == "vpc-"
    error_message = "The vpc value must be a valid vpc, starting with \"vpc-\"."
  }
}

variable "source_ami" {
  type        = string
  default = ""
  description = "The id of the source image (AMI) to use."

  validation {
    condition     = length(var.source_ami) > 4 && substr(var.source_ami, 0, 4) == "ami-"
    error_message = "The source_ami value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "security_group" {
  type        = string
  default = ""
  description = "The security group to use."

  validation {
    condition     = length(var.security_group) > 3 && substr(var.security_group, 0, 3) == "sg-"
    error_message = "The security_group value must be a valid security group name, starting with \"sg-\"."
  }
}

variable "subnet" {
  type        = string
  default = ""
  description = "The subnet to use."

  validation {
    condition     = length(var.subnet) > 3 && substr(var.subnet, 0, 7) == "subnet-"
    error_message = "The subnet value must be a valid subnet name, starting with \"subnet-\"."
  }
}

variable "ssh_location" {
  type        = string
  default = "/var/lib/jenkins/.ssh/instanacd-new"
  description = "The ssh key location."

  validation {
    condition     = length(var.ssh_location) > 0
    error_message = "The ssh key_location value must be a valid path to ssh private key."
  }
}

variable "secrets_path" {
  type        = string
  default = "/mnt/efs/data/secrets/chef.yml"
  description = "The chef secrets file path."

  validation {
    condition     = length(var.secrets_path) > 0
    error_message = "The secrets_path value must be a valid path to chef secrets file."
  }
}

variable "purpose" {
  type        = string
  default = "fleet"
  description = "The purpose tag value"

  validation {
    condition     = length(var.purpose) > 0
    error_message = "The purpose value must not be blank."
  }
}
