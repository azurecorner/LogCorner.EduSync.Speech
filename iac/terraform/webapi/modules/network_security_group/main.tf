resource "azurerm_network_security_group" "network_security_group" {
  name                = var.network_security_group_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "network_security_rules" {
  for_each                    = var.nsgrules
  name                        = each.key
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.network_security_group.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_network_security_group_association" {
  for_each = { for idx, subnet_id in var.subnet_ids : idx => subnet_id }

  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.network_security_group.id
}
