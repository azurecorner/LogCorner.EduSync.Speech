
resource "azurerm_private_endpoint" "private_endpoint" {
  location            = var.resource_group_location
  name                = var.private_endpoint_name
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  private_service_connection {
    is_manual_connection           = false
    name                           = var.private_service_connection_name
    private_connection_resource_id = var.private_connection_resource_id
    subresource_names              = [var.private_service_connection_subresource_name]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
  tags = var.tags
}