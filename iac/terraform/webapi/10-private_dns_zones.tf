
resource "azurerm_private_dns_zone" "private_dns_zone_azurewebsites" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_resource_group.resource_group]
}

resource "azurerm_private_dns_zone" "api_private_dns_zone" {
  name                = "cloud-devops-craft.com"
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_resource_group.resource_group
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link-api" {
  name                  = "${var.virtual_network_name}-${azurerm_private_dns_zone.api_private_dns_zone.name}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.api_private_dns_zone.name
  virtual_network_id    = module.virtual_network.virtual_network_id
  depends_on            = [azurerm_private_dns_zone.api_private_dns_zone, module.virtual_network]
}


resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link_azurewebsites" {
  name                  = "${var.virtual_network_name}-${azurerm_private_dns_zone.private_dns_zone_azurewebsites.name}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone_azurewebsites.name
  virtual_network_id    = module.virtual_network.virtual_network_id
  depends_on            = [azurerm_private_dns_zone.private_dns_zone_azurewebsites, module.virtual_network]
}
