terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
      version = "2.39.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
  }
  required_version = ">= 1.2.0"
}
