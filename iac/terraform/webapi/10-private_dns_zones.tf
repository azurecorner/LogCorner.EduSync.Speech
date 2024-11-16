
resource "azurerm_private_dns_zone" "private_dns_zone_azurewebsites" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name
  depends_on = [ azurerm_resource_group.resource_group ]
}


resource "azurerm_private_dns_zone" "api_private_dns_zone" {
  name                = "cloud-devops-craft.com"
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_resource_group.resource_group
  ]
}
