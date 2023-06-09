packer {
  required_plugins {
    googlecompute = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

source "googlecompute" "autogenerated_1" {
  project_id   = "${var.project_id}"
  source_image = "${var.source_image}"
  image_name   = format("base-bionic-%s-%s", var.instana_region, formatdate("YYYYMMDDHHmmss", timestamp()))
  metadata = {
    enable-oslogin = "false"
  }
  network          = "${var.network}"
  subnetwork       = "${var.subnetwork}"
  omit_external_ip = "true"
  ssh_username     = "packer"
  use_internal_ip  = "true"
  zone             = "${var.zone}"
  disk_size        = "${var.disk_size}"
  disk_type        = "pd-ssd"
  image_labels = {
    distro        = "bionic"
    instana-image = "base"
    purpose       = "${var.purpose}"
  }
}

build {
  sources = ["source.googlecompute.autogenerated_1"]

  provisioner "file" {
    destination = "/tmp/provision.sh"
    source      = "provision.sh"
  }

  provisioner "shell" {
    inline = ["sudo chmod +x /tmp/provision.sh", "sudo PACKER_BUILD_NAME=fleet_amis /tmp/provision.sh base ${var.apt_region} ${var.apt_state} ${var.instana_region}"]
  }

}
