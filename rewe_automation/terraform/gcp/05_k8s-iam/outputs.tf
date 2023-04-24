output "dns_access_service_account" {
  description = "The service account with permissions to manage DNS records"
  value       = google_service_account.dns.email
}

output "raws_spans_service_account" {
  description = "The service account for raw spans access"
  value       = google_service_account.raw_spans.email
}

output "raws_spans_service_account_key" {
  description = "The service account key for raw spans access"
  value       = base64decode(google_service_account_key.raw_spans.private_key)
  sensitive   = true
}

output "raws_spans_access_key_id" {
  description = "The access key id for S3 compatible raws spans bucket access"
  value       = google_storage_hmac_key.raw_spans.access_id
  sensitive   = true
}

output "raws_spans_secret_access_key" {
  description = "The secret access key for S3 compatible raws spans bucket access"
  value       = google_storage_hmac_key.raw_spans.secret
  sensitive   = true
}
