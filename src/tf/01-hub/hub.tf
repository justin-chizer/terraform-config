data "terraform_remote_state" "hub" {
  backend = "azurerm"

  config = {
    resource_group_name  = "avid-hub"
    storage_account_name = "chizerstorageaccount"
    container_name       = "tfbackend"
    key                  = "prod.terraform.tfstate"
    subscription_id      = var.subscription_id
    client_id            = var.client_id
    client_secret        = var.client_secret
    tenant_id            = var.tenant_id
  }
}
data "azurerm_resource_group" "hub" {
  name = "avid-hub"
}

data "azurerm_key_vault" "hub" {
  name                = "chizervault"
  resource_group_name = "avid-hub"
}

data "azurerm_storage_account" "hub" {
  name                = "chizerstorageaccount"
  resource_group_name = "avid-hub"
}


resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  location            = data.azurerm_resource_group.hub.location
  resource_group_name = data.azurerm_resource_group.hub.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    type = "suas"
  }
}