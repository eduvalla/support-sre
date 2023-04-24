output "kubeconfig" {
  description = "The gcloud command to get cluster credentials for kubectl"
  value       = "gcloud container clusters get-credentials --zone ${var.zone} --project ${var.project} ${module.naming.id}"
}

output "ca_certificate" {
  description = "CA certificate (base64-encoded)"
  sensitive   = true
  value       = google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
}

output "endpoint" {
  description = "The Kubernetes API server endpoint"
  value       = google_container_cluster.cluster.endpoint
  depends_on  = [
    /* Nominally, the endpoint is populated as soon as it is known to Terraform.
    * However, the cluster may not be in a usable state yet. Therefore any
    * resources dependent on the cluster being up will fail to deploy. With
    * this explicit dependency, dependent resources can wait for the cluster
    * to be up.
    */
    google_container_cluster.cluster
  ]
}

output "name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.cluster.name
}

output "location" {
  description = "The location of the GKE cluster"
  value       = google_container_cluster.cluster.location
}
