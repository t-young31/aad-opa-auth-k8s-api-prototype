resource "azurerm_kubernetes_cluster" "sample" {
  location            = azurerm_resource_group.aks.location
  name                = "cluster-${var.azure_suffix}"
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "dns-${var.azure_suffix}"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
    }
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

resource "azurerm_role_assignment" "k8s_can_use_acr" {
  scope                = azurerm_container_registry.aks.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.sample.kubelet_identity[0].object_id
}
