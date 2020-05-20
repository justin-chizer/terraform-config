# Creating the Hub
resource "azurerm_resource_group" "hub" {
  name     = var.hub_rg_name
  location = var.hub_region

  tags = {
    type = "suas"
  }
}

resource "azurerm_network_security_group" "hub" {
  name                = var.hub_nsg_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

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

resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    type = "suas"
  }
}

resource "azurerm_subnet" "core" {
  name                 = var.core_subnet_name
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]

  #   delegation {
  #     name = "acctestdelegation"

  #     service_delegation {
  #       name    = "Microsoft.ContainerInstance/containerGroups"
  #       actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
  #     }
  #   }
}
resource "azurerm_subnet_network_security_group_association" "core" {
  subnet_id                 = azurerm_subnet.core.id
  network_security_group_id = azurerm_network_security_group.hub.id
}

resource "azurerm_subnet" "mgmt" {
  name                 = var.mgmt_subnet_name
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]

  #   delegation {
  #     name = "acctestdelegation"

  #     service_delegation {
  #       name    = "Microsoft.ContainerInstance/containerGroups"
  #       actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
  #     }
  #   }
}
resource "azurerm_subnet_network_security_group_association" "mgmt" {
  subnet_id                 = azurerm_subnet.mgmt.id
  network_security_group_id = azurerm_network_security_group.hub.id
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.3.0/24"]
}


resource "azurerm_public_ip" "bastion" {
  name                = "bation-hub-ip"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "hub-bastion"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

################################################################
# Create the Debian Core VM
resource "azurerm_network_interface" "core" {
  name                = "vm-nic"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.core.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_linux_virtual_machine" "core" {
  name                            = var.avid-core-vm
  resource_group_name             = azurerm_resource_group.hub.name
  location                        = azurerm_resource_group.hub.location
  size                            = "Standard_D2S_v3" #Does not support acc networking
  admin_username                  = "adminuser"
  admin_password                  = "Password!23"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.core.id,
  ]

  # admin_ssh_key {
  #   username = "adminuser"
  #   public_key = file("~/.ssh/id_rsa.pub")
  # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128 # P10 Premium SSD. Should be at least P30 for prod
  }

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10"
    version   = "latest"
  }
}


######################################################################

# MGMT subnet resources
#KeyVault management. Have endpoint be in the VNet
#Storage account management


######################################################################

# VNet for Show 1 peered to hub
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

resource "azurerm_linux_virtual_machine_scale_set" "show" {
  name                            = "show-vmss"
  resource_group_name             = azurerm_resource_group.show.name
  location                        = azurerm_resource_group.show.location
  sku                             = "Standard_D2S_v3"
  instances                       = 2
  admin_username                  = "adminuser"
  admin_password                  = "Password!23"
  disable_password_authentication = false

  #   admin_ssh_key {
  #     username   = "adminuser"
  #     public_key = file("~/.ssh/id_rsa.pub")
  #   }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "show"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.show.id
    }
  }
}