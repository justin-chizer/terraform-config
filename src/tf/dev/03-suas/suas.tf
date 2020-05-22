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

data "terraform_remote_state" "core" {
  backend = "azurerm"

  config = {
    resource_group_name  = "avid-hub"
    storage_account_name = "chizerstorageaccount"
    container_name       = "tfbackend"
    key                  = "prodcore.terraform.tfstate"
    subscription_id      = var.subscription_id
    client_id            = var.client_id
    client_secret        = var.client_secret
    tenant_id            = var.tenant_id
  }
}

data "azurerm_virtual_network" "core" {
  name                = var.hub_vnet_name
  resource_group_name = data.azurerm_resource_group.hub.name
}

data "terraform_remote_state" "network" {
  backend = "azurerm"

  config = {
    resource_group_name  = "avid-hub"
    storage_account_name = "chizerstorageaccount"
    container_name       = "tfbackend"
    key                  = "prodshownetwork.terraform.tfstate"
    subscription_id      = var.subscription_id
    client_id            = var.client_id
    client_secret        = var.client_secret
    tenant_id            = var.tenant_id
  }
}

"azurerm_virtual_network" "show" {
  name                = var.show_vnet_name
  resource_group_name = data.azurerm_resource_group.hub.name
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