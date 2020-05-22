terraform {
  backend "azurerm" {
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