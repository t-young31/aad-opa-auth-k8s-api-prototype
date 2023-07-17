resource "azurerm_resource_group" "aks" {
  location = "uksouth"
  name     = "rg-aks-${var.azure_suffix}"
}

resource "azurerm_container_registry" "aks" {
  name                          = var.acr_name
  location                      = azurerm_resource_group.aks.location
  resource_group_name           = azurerm_resource_group.aks.name
  sku                           = "Standard"
  admin_enabled                 = true
  public_network_access_enabled = true
}
