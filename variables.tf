# variables.tf
#
# This file defines the input variables for the angular-webapp module.
# These variables allow users to customize the deployment of the Angular web application infrastructure.

variable "application_name" {
  description = "The name of the application (e.g., 'sos-angular-frontend'). Used for naming resources."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy resources into. If create_resource_group is true, this will be the name of the new RG."
  type        = string
}

variable "create_resource_group" {
  description = "Whether to create a new resource group or use an existing one."
  type        = bool
  default     = false
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., 'dev', 'test', 'prod')."
  type        = string
}

variable "application_criticality" {
  description = "The criticality of the application (e.g., 'Tier1', 'Tier3'). Used for tagging."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to all provisioned resources."
  type        = map(string)
  default     = {}
}

# App Service Plan Configuration
variable "create_app_service_plan" {
  description = "Whether to create a new App Service Plan or use an existing one."
  type        = bool
  default     = true # Default to creating a new plan
}

variable "existing_app_service_plan_id" {
  description = "The ID of an existing App Service Plan to use. Required if create_app_service_plan is false."
  type        = string
  default     = null
}

variable "app_service_plan_sku_tier" {
  description = "The SKU tier for the App Service Plan (e.g., 'PremiumV2', 'Standard', 'Basic')."
  type        = string
  default     = "PremiumV2" # Matches P2v2 tier
}

variable "app_service_plan_sku_size" {
  description = "The SKU size for the App Service Plan (e.g., 'P2v2', 'S1', 'B1')."
  type        = string
  default     = "P2v2" # Matches P2v2 size
}

variable "app_service_plan_os_type" {
  description = "The operating system type for the App Service Plan ('Windows' or 'Linux')."
  type        = string
  default     = "Windows" # Assuming Windows based on your previous observation
}

# App Service Configuration
variable "app_service_kind" {
  description = "The kind of App Service to create (e.g., 'app', 'api', 'functionapp'). 'app' is standard for web apps."
  type        = string
  default     = "app"
}

variable "app_service_name" {
  description = "The name of the App Service. If null, a unique name will be generated."
  type        = string
  default     = null
}

variable "app_settings" {
  description = "A map of application settings to apply to the App Service."
  type        = map(string)
  default     = {} # Allows caller to pass custom app settings
}

variable "site_config_settings" {
  description = "An object containing site_config settings for the App Service (e.g., { http20_enabled = true, always_on = true })."
  type        = map(any) # Use 'any' to allow flexible site_config properties
  default     = {
    http20_enabled = true
    always_on      = true
    # For static content, you might not need a specific dotnet_version or node_version here,
    # as the App Service just serves the static files.
    # If using WEBSITE_RUN_FROM_PACKAGE, ensure it's configured in app_settings.
  }
}

# Networking (Private Endpoint for App Service)
variable "create_private_endpoint" {
  description = "Flag to enable creation of a private endpoint for the App Service."
  type        = bool
  default     = true # Best practice for secure environments
}

variable "private_endpoint_subnet_id" {
  description = "The ID of the subnet where the private endpoint will be deployed. Required if create_private_endpoint is true."
  type        = string
  nullable    = false
}

variable "private_dns_zone_ids" {
  description = "A list of Private DNS Zone IDs to link the Private Endpoint to (e.g., for privatelink.azurewebsites.net)."
  type        = list(string)
  default     = []
}

# Application Insights Configuration
variable "enable_application_insights" {
  description = "Flag to enable creation of Azure Application Insights for monitoring the web app."
  type        = bool
  default     = true
}

variable "app_insights_daily_data_cap_in_gb" {
  description = "The daily data volume cap in GB for Application Insights."
  type        = number
  default     = 1 # Default to 1 GB
}

variable "app_insights_retention_in_days" {
  description = "The number of days to retain data in Application Insights."
  type        = number
  default     = 90 # Default to 90 days
}
