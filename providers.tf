# providers.tf
#
# This file configures the Azure provider for the angular-webapp module.

provider "azurerm" {
  features {} # This block enables the Azure Provider Features configuration.
              # It's a best practice to include it.
}
