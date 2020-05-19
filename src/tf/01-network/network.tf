#Creates VNet and Subnet
module "VNet-1" {
  source                  = "./../modules/azure-vnet"
  location                = azurerm_resource_group.demo.location
  resource_group_name     = azurerm_resource_group.demo.name
  vnet_name               = var.vnet_name
  address_space           = ["10.0.0.0/16"]

  subnet_name             = var.subnet_name
  address_prefix          = "10.0.0.0/22"
  environment             = "prod"
}