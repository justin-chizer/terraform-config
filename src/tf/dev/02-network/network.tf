resource "azurerm_resource_group" "show" {
  name     = var.show_rg_name
  location = var.show_region

  tags = {
    type = "suas"
  }
}

resource "azurerm_network_security_group" "show" {
  name                = var.show_nsg_name
  location            = azurerm_resource_group.show.location
  resource_group_name = azurerm_resource_group.show.name

  #   security_rule {
  #     name                       = "test123"
  #     priority                   = 100
  #     direction                  = "Inbound"
  #     access                     = "Allow"
  #     protocol                   = "Tcp"
  #     source_port_range          = "*"
  #     destination_port_range     = "*"
  #     source_address_prefix      = "*"
  #     destination_address_prefix = "*"
  #   }
  tags = {
    type = "suas"
  }
}

resource "azurerm_virtual_network" "show" {
  name                = var.show_vnet_name
  location            = azurerm_resource_group.show.location
  resource_group_name = azurerm_resource_group.show.name
  address_space       = ["10.1.0.0/16"]

  tags = {
    type = "suas"
  }
}

resource "azurerm_subnet" "show" {
  name                 = var.show_subnet_name
  resource_group_name  = azurerm_resource_group.show.name
  virtual_network_name = azurerm_virtual_network.show.name
  address_prefixes     = ["10.1.1.0/24"]

  #   delegation {
  #     name = "acctestdelegation"

  #     service_delegation {
  #       name    = "Microsoft.ContainerInstance/containerGroups"
  #       actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
  #     }
  #   }
}
resource "azurerm_subnet_network_security_group_association" "show" {
  subnet_id                 = azurerm_subnet.show.id
  network_security_group_id = azurerm_network_security_group.show.id
}

# Peer the VNets
resource "azurerm_virtual_network_peering" "hub" {
  name                      = "hubtoshow-1"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.show.id
}

resource "azurerm_virtual_network_peering" "show" {
  name                      = "show-1tohub"
  resource_group_name       = azurerm_resource_group.show.name
  virtual_network_name      = azurerm_virtual_network.show.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}