// service account for access to the container registry

data "google_storage_bucket" "registry" {
  name = "artifacts.instana-solution-architects.appspot.com"
}

resource "google_service_account" "registry" {
  account_id   = module.naming.id
  display_name = "Registry read access"
}

resource "google_storage_bucket_iam_member" "registry" {
  bucket = data.google_storage_bucket.registry.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.registry.email}"
}

resource "google_service_account_key" "registry" {
  service_account_id = google_service_account.registry.name
}
