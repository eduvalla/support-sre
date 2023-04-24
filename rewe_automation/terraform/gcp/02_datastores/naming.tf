module "naming" {
  source      = "../_modules/naming"
  name        = "datastores"
  environment = var.environment
}
