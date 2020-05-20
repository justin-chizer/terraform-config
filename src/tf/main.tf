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
    disk_size_gb         = 128 # P10 Premium SSD. Should be P30 for prod
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
