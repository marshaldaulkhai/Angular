# examples/example.tf
#
# This file demonstrates how to use the angular-webapp module.
# It's intended for local testing and development of the module.

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = { # Used for generating unique names in this example
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Ensure you are authenticated to Azure (e.g., via 'az login')
  # or provide subscription_id, client_id, client_secret etc. here.
}

# Generate a unique suffix for resource group and App Service names
resource "random_string" "unique_suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

# Define test variables
locals {
  test_resource_group_name = "rg-angular-appservice-test-${random_string.unique_suffix.result}"
  test_location            = "eastus" # Choose an Azure region
  test_application_name    = "sosangular"
  test_environment         = "dev"
  test_criticality         = "Tier3"
  test_tags = {
    ManagedBy = "Terraform"
    Project   = "SOSMigration"
  }
  # IMPORTANT: Replace with a real subnet ID from your test VNet for private endpoint testing
  # This subnet must be delegated for Private Link services.
  test_private_endpoint_subnet_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_TEST_VNET_RG/providers/Microsoft.Network/virtualNetworks/YOUR_TEST_VNET/subnets/YOUR_TEST_PRIVATE_SUBNET"
  # IMPORTANT: Replace with real Private DNS Zone ID for privatelink.azurewebsites.net
  # You might need to create this zone if it doesn't exist in your test environment.
  test_private_dns_zone_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_TEST_DNS_RG/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
}


# --- Scenario 1: Create a new App Service Plan and Web App ---
module "angular_webapp_new_plan_instance" {
  source = "../../" # Points to the root of your module directory

  application_name        = "${local.test_application_name}-newplan"
  resource_group_name     = local.test_resource_group_name
  create_resource_group   = true # Create a new RG for this example
  location                = local.test_location
  environment             = local.test_environment
  application_criticality = local.test_criticality
  tags                    = local.test_tags

  create_app_service_plan = true # Create a new App Service Plan
  app_service_plan_sku_tier = "Standard"
  app_service_plan_sku_size = "S1"
  app_service_plan_os_type  = "Windows"

  create_private_endpoint    = true
  private_endpoint_subnet_id = local.test_private_endpoint_subnet_id
  private_dns_zone_ids       = [local.test_private_dns_zone_id]

  enable_application_insights = true

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1" # Common for static apps deployed to App Service
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "false" # Build locally, deploy package
    "SOME_ANGULAR_API_URL" = "https://your-backend-api.azurewebsites.net" # Example app setting
  }
  site_config_settings = {
    http20_enabled = true
    always_on      = true
  }
}

# --- Scenario 2: Use an existing App Service Plan ---
# To test this, you would uncomment this block and replace
# 'your_existing_app_service_plan_id' with a real ID from your Azure environment.
/*
resource "azurerm_resource_group" "existing_plan_rg" {
  name     = "rg-existing-plan-test" # An existing RG for this test
  location = "eastus"
}

module "angular_webapp_existing_plan_instance" {
  source = "../../"

  application_name        = "${local.test_application_name}-existingplan"
  resource_group_name     = azurerm_resource_group.existing_plan_rg.name # Use an existing RG
  create_resource_group   = false # Do not create a new RG
  location                = local.test_location
  environment             = local.test_environment
  application_criticality = local.test_criticality
  tags                    = local.test_tags

  create_app_service_plan    = false # Use an existing App Service Plan
  existing_app_service_plan_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_EXISTING_PLAN_RG/providers/Microsoft.Web/serverFarms/YOUR_EXISTING_APP_SERVICE_PLAN_NAME" # REPLACE WITH REAL ID

  create_private_endpoint    = true
  private_endpoint_subnet_id = local.test_private_endpoint_subnet_id
  private_dns_zone_ids       = [local.test_private_dns_zone_id]

  enable_application_insights = true

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "SOME_OTHER_API_URL" = "https://another-backend-api.azurewebsites.net"
  }
  site_config_settings = {
    http20_enabled = true
    always_on      = true
  }
}
*/

# Output the hostnames for easy access after deployment
output "angular_webapp_new_plan_url" {
  description = "The URL of the deployed Angular web app (new plan)."
  value       = module.angular_webapp_new_plan_instance.app_service_default_hostname
}

output "angular_webapp_new_plan_app_insights_key" {
  description = "The Instrumentation Key for the new plan's App Insights."
  value       = module.angular_webapp_new_plan_instance.application_insights_instrumentation_key
  sensitive   = true
}

/*
# Uncomment if testing existing plan scenario
output "angular_webapp_existing_plan_url" {
  description = "The URL of the deployed Angular web app (existing plan)."
  value       = module.angular_webapp_existing_plan_instance.app_service_default_hostname
}
*/
