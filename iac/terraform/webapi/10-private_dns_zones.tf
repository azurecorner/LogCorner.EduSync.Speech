
resource "azurerm_private_dns_zone" "private_dns_zone_azurewebsites" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name
}


