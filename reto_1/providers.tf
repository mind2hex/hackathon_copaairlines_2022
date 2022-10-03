# Configure the Azure provider
terraform {
	required_version = ">=0.14.9"
	required_providers {
		azurerm = {
			source  = "hashicorp/azurerm"
			version = "~>3.0.0"
		}
	}
}

provider "azurerm" {
  # usar los parametros inferiores en caso de requerir usar los ID's
  # subscription_id = ""
  # client_id       = ""
  # client_secret   = ""
  # tenant_id       = ""
  features {}
}
