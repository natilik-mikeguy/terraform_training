output "location" {
  value = azurerm_resource_group.example.location
}

output "url" {
  value = "http://${azurerm_linux_virtual_machine.example.public_ip_address}"
}
