resource "aws_eks_cluster" "eks-cluster" {
  name     = "${local.cluster_name}"
  version = "${var.cluster_version}"
  role_arn = ""
  vpc_config {
    subnet_ids = []
  }
}