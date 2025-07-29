# main.tf
#
# This file defines the core Azure resources for the angular-webapp module.
# It includes the App Service Plan, App Service, Private Endpoint,
# User-Assigned Managed Identity, and Application Insights.

# Conditionally create a Resource Group if specified by the user
resource "azurerm_resource_group" "webapp_rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Conditionally create an Azure App Service Plan
resource "azurerm_app_service_plan" "webapp_plan" {
  count               = var.create_app_service_plan ? 1 : 0
  name                = local.app_service_plan_final_name
  location            = var.location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.webapp_rg[0].name : var.resource_group_name
  kind                = var.app_service_plan_os_type
  sku {
    tier = var.app_service_plan_sku_tier
    size = var.app_service_plan_sku_size
  }
  tags = local.common_tags
}

# Azure App Service for the Angular Web App
resource "azurerm_app_service" "angular_webapp" {
  name                = local.app_service_final_name
  location            = var.location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.webapp_rg[0].name : var.resource_group_name
  app_service_plan_id = var.create_app_service_plan ? azurerm_app_service_plan.webapp_plan[0].id : var.existing_app_service_plan_id
  kind                = var.app_service_kind

  # Site configuration for the App Service
  site_config {
    # Merge default site_config settings with any provided by the caller
    dynamic "setting" {
      for_each = var.site_config_settings
      content {
        name  = setting.key
        value = setting.value
      }
    }
  }

  # Application settings for the App Service
  app_settings = var.app_settings # Directly use the map passed by the caller

  # Managed Identity for the App Service
  identity {
    type = "SystemAssigned" # System-assigned identity is often simpler for App Services
  }

  tags = local.common_tags
}

# Azure Application Insights for monitoring (optional)
resource "azurerm_application_insights" "app_insights" {
  count                = var.enable_application_insights ? 1 : 0
  name                 = "${var.application_name}-appinsights-${var.environment}"
  location             = var.location
  resource_group_name  = var.create_resource_group ? azurerm_resource_group.webapp_rg[0].name : var.resource_group_name
  application_type     = "Web" # Appropriate for web applications
  daily_data_cap_in_gb = var.app_insights_daily_data_cap_in_gb
  retention_in_days    = var.app_insights_retention_in_days
  tags                 = local.common_tags
}

# Private Endpoint for the App Service
resource "azurerm_private_endpoint" "angular_app_service_pe" {
  count             = var.create_private_endpoint ? 1 : 0
  name              = "${var.application_name}-pe-appservice-${var.environment}"
  resource_group_name = var.create_resource_group ? azurerm_resource_group.webapp_rg[0].name : var.resource_group_name
  location          = var.location
  subnet_id         = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.application_name}-psc-appservice-${var.environment}"
    private_connection_resource_id = azurerm_app_service.angular_webapp.id
    is_manual_connection           = false
    subresource_names              = ["sites"] # For App Services
  }

  # This is crucial for DNS resolution over Private Link
  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = var.private_dns_zone_ids # Expecting privatelink.azurewebsites.net for App Service
    }
  }

  tags = local.common_tags
}

# Note: Azure Front Door or Application Gateway would typically be provisioned
# by a higher-level module (like the three-layered-serverless-app-pattern)
# and would reference the 'default_host_name' output of this module as its origin.
