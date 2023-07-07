terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
      version = "2.39.0"
    }
  }
  required_version = ">= 1.2.0"
}
