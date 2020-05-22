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

resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  location            = data.azurerm_resource_group.hub.location
  resource_group_name = data.azurerm_resource_group.hub.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    type = "suas"
  }
}

resource "azurerm_network_security_group" "hub" {
  name                = var.hub_nsg_name
  location            = data.azurerm_resource_group.hub.location
  resource_group_name = data.azurerm_resource_group.hub.name

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

resource "azurerm_subnet" "core" {
  name                 = var.core_subnet_name
  resource_group_name  = data.azurerm_resource_group.hub.name
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

# Create the Debian Core VM
resource "azurerm_network_interface" "core" {
  name                = "vm-nic"
  location            = data.azurerm_resource_group.hub.location
  resource_group_name = data.azurerm_resource_group.hub.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.core.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_linux_virtual_machine" "core" {
  name                            = var.avid-core-vm
  resource_group_name             = data.azurerm_resource_group.hub.name
  location                        = data.azurerm_resource_group.hub.location
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
