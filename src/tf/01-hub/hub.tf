data "azurerm_resource_group" "hub" {
  name     = "avid-core"
  location = "westus2"
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