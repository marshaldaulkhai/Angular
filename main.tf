terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "example-app-rg"
  location = var.location
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "example-appservice-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "S1"
  os_type  = "Windows"
}

resource "azurerm_windows_web_app" "example" {
  name                = var.web_app_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      current_stack = "dotnet"
      dotnet_version = "v4.0"
    }
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }
}

resource "azurerm_app_service_source_control" "example" {
  app_id               = azurerm_windows_web_app.example.id
  repo_url             = "https://github.com/your/repo.git"
  branch               = "main"
  use_manual_integration = true
}
