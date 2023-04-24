terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    random = {
      source = "hashicorp/random"
      version = "~> 3.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.0.0"
    }

  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

module "vpc_network" {
  source = "./networks/"
  tagprefix = var.tagprefix
}

module "database_instances" {
  source = "./databases/"
#  subnet = module.vpc_network.support_sre_db_subnet
  ami = data.aws_ami.ubuntu_20_04
  tagprefix = var.tagprefix
  vpc_id = module.vpc_network.vpc_id
  db_subnet = module.vpc_network.support_sre_db_subnet
}

module "cluster" {
  source = "./cluster/"
  tagprefix = var.tagprefix
  cluster_version = var.cluster_version
}
