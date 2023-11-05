/*resource "azurerm_route_table" "rtmisql" {
  name                          = "rt-misql-test"
  location                      = azurerm_resource_group.rgaks.location
  resource_group_name           = azurerm_resource_group.rgaks.name
  disable_bgp_route_propagation = false

    route {
      name           = "route1"
      address_prefix = "10.3.1.0/24"
      next_hop_type  = "VnetLocal"
    }

}

resource "azurerm_subnet_route_table_association" "assocrtmisql" {
  subnet_id      = azurerm_subnet.db.id
  route_table_id = azurerm_route_table.rtmisql.id
}*/

  resource "azurerm_mssql_server" "azsqlsrv" {
  name                         = "sql-server-akstest01"
  resource_group_name          = azurerm_resource_group.rgaks.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "maniaX"
  administrator_login_password = "thisIsDog11"

}

resource "azurerm_sql_database" "azsqldb" {
  name                = "sqlappdb"
  resource_group_name = azurerm_resource_group.rgaks.name
  location            = var.location
  server_name         = azurerm_mssql_server.azsqlsrv.name
}


resource "azurerm_private_endpoint" "pesqldb" {
  name                = "pe-sqldb-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.rgaks.name
  subnet_id           = azurerm_subnet.db.id

  private_service_connection {
    name                           = "pse-privateserviceconnection"
    private_connection_resource_id = azurerm_mssql_server.azsqlsrv.id
    subresource_names              = [ "sqlServer" ]
    is_manual_connection           = false
  }
}