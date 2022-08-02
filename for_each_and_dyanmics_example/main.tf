terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.14.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-for-each-and-dynamics"
  location = "uksouth"
}

resource "azurerm_network_security_group" "example" {
  for_each            = { for key, value in var.nsgs : value.nsg_name => value }
  name                = each.key
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  dynamic "security_rule" {
    for_each = each.value.nsg_rules
    content {
      name                       = security_rule.value.rule_name
      priority                   = security_rule.value.rule_priority
      direction                  = security_rule.value.rule_direction
      access                     = security_rule.value.rule_action
      protocol                   = title(lower(security_rule.value.rule_proto))
      source_port_range          = security_rule.value.rule_source_port
      destination_port_range     = security_rule.value.rule_dest_port
      source_address_prefix      = security_rule.value.rule_source_addr
      destination_address_prefix = security_rule.value.rule_dest_addr

    }
  }
}
