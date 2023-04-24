resource "google_storage_bucket" "raw_spans" {
  name          = module.naming.id
  location      = var.region
  force_destroy = true
  lifecycle_rule {
    condition {
      age = var.raw_spans_retention_days
    }
    action {
      type = "Delete"
    }
  }
}
