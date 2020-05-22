# Creating the Hub
resource "azurerm_resource_group" "hub" {
  name     = "avid-hub"
  location = "westus2"

  tags = {
    type = "suas"
  }
}

resource "azurerm_storage_account" "hub" {
  name                     = "chizerstorageaccount" # Global unique
  resource_group_name      = azurerm_resource_group.hub.name
  location                 = azurerm_resource_group.hub.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"


  tags = {
    type = "suas"
  }
}

resource "azurerm_storage_container" "hub" {
  name                  = "tfbackend"
  storage_account_name  = azurerm_storage_account.hub.name
  container_access_type = "private"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "hub" {
  name                        = "chizervault"
  location                    = azurerm_resource_group.hub.location
  resource_group_name         = azurerm_resource_group.hub.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  purge_protection_enabled    = false

  sku_name = "standard"

  tags = {
    type = "suas"
  }
}