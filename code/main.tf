#Resource group creation
resource "azurerm_resource_group" "rgaks" {
    name     = "rg-aks-testing"
    location = var.location
}

#Vnet and subnet creation
resource "azurerm_virtual_network" "aksvnet" {
    name                = "vnet-aks-spoke1"
    address_space       = ["10.3.0.0/16"]
    location            = azurerm_resource_group.rgaks.location
    resource_group_name = azurerm_resource_group.rgaks.name
}
resource "azurerm_subnet" "backend" {
    name                 = "snet-backend"
    resource_group_name  = azurerm_resource_group.rgaks.name
    virtual_network_name = azurerm_virtual_network.aksvnet.name
    address_prefixes     = ["10.3.1.0/24"]
}
resource "azurerm_subnet" "db" {
    name                 = "snet-db"
    resource_group_name  = azurerm_resource_group.rgaks.name
    virtual_network_name = azurerm_virtual_network.aksvnet.name
    address_prefixes     = ["10.3.2.0/24"]
    /*delegation {
      name = "misqldelegation"
      service_delegation {
        name    = "Microsoft.Sql/managedInstances"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }*/
}

#NSG creation
resource "azurerm_network_security_group" "backend" {
    name                = "nsg-aks-backend"
    location            = azurerm_resource_group.rgaks.location
    resource_group_name = azurerm_resource_group.rgaks.name
}

resource "azurerm_network_security_group" "db" {
    name                = "nsg-aks-db"
    location            = azurerm_resource_group.rgaks.location
    resource_group_name = azurerm_resource_group.rgaks.name
    security_rule {
    name                       = "MSSQL"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "10.3.1.0/24"
    destination_address_prefix = "*"
  }
}
#NSG association
resource "azurerm_subnet_network_security_group_association" "assocdbnsg" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.db.id
}

resource "azurerm_subnet_network_security_group_association" "assocbackendnsg" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.backend.id
}