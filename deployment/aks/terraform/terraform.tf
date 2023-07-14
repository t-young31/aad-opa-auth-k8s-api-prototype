terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.65.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.7.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "azurerm" {
  features {}
}
