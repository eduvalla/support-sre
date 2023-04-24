module "naming" {
  source         = "cloudposse/label/null"
  version        = "v0.25.0"
  label_order    = ["name", "environment"]
  name           = var.name
  environment    = var.environment
  label_key_case = "lower"
}
