locals {
  instana_repository = var.instana_registry == "containers.instana.io" ? "instana/release/product" : "instana-solution-architects/infrastructure/self-hosted"
}
