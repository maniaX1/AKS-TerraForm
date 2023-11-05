output "aksrgname" {
  value = azurerm_resource_group.rgaks.name
}

output "aksvnetid" {
  value = azurerm_virtual_network.aksvnet.id
}

output "snetbackendid" {
  value = azurerm_subnet.backend.id
}

output "snetdbid" {
  value = azurerm_subnet.db.id
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.akscluster.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.akscluster.kube_config_raw
  sensitive = true
}