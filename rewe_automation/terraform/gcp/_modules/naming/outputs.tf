output "id" {
  description = "The ID string to use for naming resources"
  value       = module.naming.id
}

output "tags" {
  description = "The tags map that can be used for resource labels"
  value       = module.naming.tags
}
