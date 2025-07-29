# locals.tf
#
# This file defines local variables for the angular-webapp module.
# These variables are derived from input variables or used for consistent naming.

locals {
  # Generate a unique name for the App Service if not provided
  # App Service names must be globally unique
  generated_app_service_name = lower(replace("${var.application_name}-${var.environment}-${random_string.suffix.result}", "-", ""))

  # Final App Service name: use provided name or generated one
  app_service_final_name = var.app_service_name != null ? var.app_service_name : local.generated_app_service_name

  # Generate a unique name for the App Service Plan if creating a new one
  generated_app_service_plan_name = lower(replace("${var.application_name}-${var.environment}-asp-${random_string.suffix.result}", "-", ""))

  # Final App Service Plan name: use generated or a default if not creating
  app_service_plan_final_name = var.create_app_service_plan ? local.generated_app_service_plan_name : "${var.application_name}-${var.environment}-asp" # Fallback if not creating new, ensures a name for tagging

  # Common tags to apply to all resources
  common_tags = merge(var.tags, {
    Environment = var.environment
    Application = var.application_name
    Criticality = var.application_criticality
  })
}

# Helper to generate a random suffix for globally unique names if needed
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}
