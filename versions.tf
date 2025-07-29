# versions.tf
#
# This file specifies the required Terraform version and Azure provider version
# for the angular-webapp module (App Service based).

terraform {
  required_version = ">= 1.0.0" # Minimum required Terraform version

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Specifies a compatible version range for the Azure provider
    }
    random = { # Used for generating unique names if needed
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
