module "naming_dns" {
  source      = "../_modules/naming"
  name        = "dns-access"
  environment = var.environment
}

resource "google_service_account" "dns" {
  account_id   = module.naming_dns.id
  display_name = "DNS access for self-hosted infra"
}

// Custom IAM role for cert-manager and external-dns
resource "google_project_iam_custom_role" "dns" {
  role_id     = "selfhostedinfra.${replace(module.naming_dns.id, "-", ".")}"
  title       = "Self-hosted Infra: DNS Access"
  description = "Self-hosted Infra: DNS Access"
  permissions = [
    "dns.changes.create",
    "dns.changes.get",
    "dns.managedZones.list",
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.delete",
    "dns.resourceRecordSets.get",
    "dns.resourceRecordSets.list",
    "dns.resourceRecordSets.update",
  ]
}

resource "google_project_iam_member" "cert_manager" {
  project = var.project
  role    = google_project_iam_custom_role.dns.name
  member  = "serviceAccount:${google_service_account.dns.email}"
}

resource "google_service_account_iam_member" "cert_manager" {
  service_account_id = google_service_account.dns.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project}.svc.id.goog[infra/cert-manager]"
}

resource "google_project_iam_member" "external_dns" {
  project = var.project
  role    = google_project_iam_custom_role.dns.name
  member  = "serviceAccount:${google_service_account.dns.email}"
}

resource "google_service_account_iam_member" "external_dns" {
  service_account_id = google_service_account.dns.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project}.svc.id.goog[infra/external-dns]"
}
