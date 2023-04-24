locals {
  cluster_name = join("-", [var.tagprefix, "eks", "${random_string.suffix}"])
}

resource "random_string" "suffix" {
  length = 8
  special = false
}