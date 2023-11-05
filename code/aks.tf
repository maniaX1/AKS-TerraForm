resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = "aks-test-cluster"
  location            = var.location
  resource_group_name = azurerm_resource_group.rgaks.name
  dns_prefix          = "akstest01"
  private_cluster_enabled = true
  

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.backend.id
  }

  identity {
    type = "SystemAssigned"
  }

}