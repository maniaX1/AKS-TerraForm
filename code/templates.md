#Storage account and container for TFSTATE
resource  "azurerm_storage_account"  "tfstate" {
    name =  "sawetestterraformstate"
    resource_group_name =  azurerm_resource_group.aks.name
    location =  var.location
    account_tier =  "Standard"
    account_replication_type =  "LRS"
    identity {
        type =  "SystemAssigned"
    }
}
resource "azurerm_storage_container" "akscontainer" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

#KeyVault for accessing storage key for TFSTATE and storing the key
resource  "azurerm_key_vault"  "akskeyvault" {
    name =  "kv-aks-test"
    resource_group_name =  azurerm_resource_group.aks.name
    location =  var.location
    sku_name =  "standard"
    tenant_id =  data.azurerm_client_config.current.tenant_id
    access_policy {
        tenant_id =  data.azurerm_client_config.current.tenant_id
        object_id =  data.azurerm_client_config.current.object_id
        key_permissions =  ["Create","Get",]
        secret_permissions =  ["Set","Get","Delete","Purge", "Recover","List"]
        storage_permissions =  ["Get","Set"]
    }
}

resource  "azurerm_key_vault_secret"  "akspsk" {
    name =  "primary-storage-key"
    value =  azurerm_storage_account.tfstate.primary_access_key
    key_vault_id =  azurerm_key_vault.akskeyvault.id
}

$ACCOUNT_KEY=(Get-AzStorageAccountKey -ResourceGroupName "rg-main-infra" -Name "sawetestterraformstate")[0].value
$ACCOUNT_KEY=(az storage account keys list --resource-group "rg-main-infra" --account-name "sawetestterraformstate" --query '[0].value' -o tsv)
$env:ARM_ACCESS_KEY=$ACCOUNT_KEY


