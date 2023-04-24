output "raw_spans_bucket" {
  description = "The name of the cloud storage bucket for raws spans"
  value = google_storage_bucket.raw_spans.name
}
