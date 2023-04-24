module "naming_rawspans" {
  source      = "../_modules/naming"
  name        = "raw-spans"
  environment = var.environment
}

resource "google_service_account" "raw_spans" {
  account_id   = module.naming_rawspans.id
  display_name = "Raw spans bucket access"
}

// Used when workload identity is disabled
resource "google_service_account_key" "raw_spans" {
  service_account_id = google_service_account.raw_spans.id
}

resource "google_storage_hmac_key" "raw_spans" {
  service_account_email = google_service_account.raw_spans.email
}

// Used when workload identity is disabled
resource "google_service_account_iam_member" "raw_spans" {
  service_account_id = google_service_account.raw_spans.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project}.svc.id.goog[core/instana-core]"
}

locals {
  raw_spans_bucket = data.terraform_remote_state.storage.outputs.raw_spans_bucket
}

resource "google_storage_bucket_iam_member" "bucket_creator" {
  bucket = local.raw_spans_bucket
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.raw_spans.email}"
}

resource "google_storage_bucket_iam_member" "bucket_reader" {
  bucket = local.raw_spans_bucket
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.raw_spans.email}"
}
