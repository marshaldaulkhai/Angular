# outputs.tf
#
# This file defines the output variables for the angular-webapp module.
# These outputs can be consumed by other Terraform configurations or modules.

output "app_service_id" {
  description = "The ID of the Azure App Service."
  value       = azurerm_app_service.angular_webapp.id
}

output "app_service_name" {
  description = "The name of the Azure App Service."
  value       = azurerm_app_service.angular_webapp.name
}

output "app_service_default_hostname" {
  description = "The default hostname (URL) of the Azure App Service."
  value       = azurerm_app_service.angular_webapp.default_host_name
}

output "app_service_plan_id" {
  description = "The ID of the Azure App Service Plan used by the App Service."
  value       = var.create_app_service_plan ? azurerm_app_service_plan.webapp_plan[0].id : var.existing_app_service_plan_id
}

output "app_service_plan_name" {
  description = "The name of the Azure App Service Plan used by the App Service."
  value       = var.create_app_service_plan ? azurerm_app_service_plan.webapp_plan[0].name : split("/", var.existing_app_service_plan_id)[8] # Extract name from ID
}

output "application_insights_instrumentation_key" {
  description = "The Instrumentation Key for the Application Insights resource (if enabled)."
  value       = var.enable_application_insights ? azurerm_application_insights.app_insights[0].instrumentation_key : null
  sensitive   = true # Mark as sensitive as it's a key
}

output "application_insights_connection_string" {
  description = "The Connection String for the Application Insights resource (if enabled)."
  value       = var.enable_application_insights ? azurerm_application_insights.app_insights[0].connection_string : null
  sensitive   = true # Mark as sensitive
}

output "private_endpoint_id" {
  description = "The ID of the Private Endpoint for the App Service (if created)."
  value       = var.create_private_endpoint ? azurerm_private_endpoint.angular_app_service_pe[0].id : null
}

output "system_assigned_identity_principal_id" {
  description = "The Principal ID of the System Assigned Managed Identity for the App Service."
  value       = azurerm_app_service.angular_webapp.identity[0].principal_id
}
