data "terraform_remote_state" "storage" {
  backend = "gcs"
  config = {
    bucket = var.state_bucket
    prefix = "${var.environment}/storage"
  }
}
