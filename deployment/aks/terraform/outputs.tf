output "key_data" {
  value     = azapi_resource.ssh_public_key.body
  sensitive = true
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.sample.name
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.sample.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.sample.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.sample.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.sample.kube_config[0].password
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.sample.kube_config[0].username
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.sample.kube_config[0].host
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.sample.kube_config_raw
  sensitive = true
}
