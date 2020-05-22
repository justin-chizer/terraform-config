output "virtual_network_name" {
  value = azurerm_virtual_network.hub.name
}

output "virtual_network_id" {
  value = azurerm_virtual_network.hub.id
}

output "subnet_id" {
  value = azurerm_subnet.core.id
}

output "subnet_name" {
  value = azurerm_subnet.core.name
}

output "linux_virtual_machine_id" {
  value = azurerm_linux_virtual_machine.core.id
}