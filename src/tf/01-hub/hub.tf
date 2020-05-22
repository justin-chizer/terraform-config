# data "terraform_remote_state" "hub" {
#   backend = "azurerm"

#   config = {
#     resource_group_name  = "avid-hub"
#     storage_account_name = "chizerstorageaccount"
#     container_name       = "tfbackend"
#     key                  = "prod.terraform.tfstate"
#     subscription_id      = var.subscription_id
#     client_id            = var.client_id
#     client_secret        = var.client_secret
#     tenant_id            = var.tenant_id
#   }
# }
# data "azurerm_resource_group" "hub" {
#   name = "avid-hub"
# }

# data "azurerm_key_vault" "hub" {
#   name                = "chizervault"
#   resource_group_name = "avid-hub"
# }

# data "azurerm_storage_account" "hub" {
#   name                = "chizerstorageaccount"
#   resource_group_name = "avid-hub"
# }

# Creating the Hub
resource "azurerm_resource_group" "core" {
  name     = var.hub_rg_name
  location = var.hub_region

  tags = {
    type = "suas"
  }
}

resource "azurerm_network_security_group" "core" {
  name                = var.hub_nsg_name
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name

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

resource "azurerm_virtual_network" "core" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    type = "suas"
  }
}

resource "azurerm_subnet" "core" {
  name                 = var.core_subnet_name
  resource_group_name  = azurerm_resource_group.core.name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes     = ["10.0.1.0/24"]
}