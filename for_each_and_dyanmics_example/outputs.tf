output "nsg_ids" {
  value = [for key, value in azurerm_network_security_group.example : value.id]
}

output "nsg_details" {
  value = [
    for key, value in azurerm_network_security_group.example :
    "${value.name} has ${length(value.security_rule[*])} rules configured."
  ]
}



