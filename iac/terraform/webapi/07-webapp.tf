# variable "linux_web_app_name" {
#   default = "datasync-web-app"
# }
# variable "service_plan_name" {
#   default = "linux-service-plan"

# }

# module "web_app" {
#   source                    = "./modules/web_app"
#   resource_group_name       = var.resource_group_name
#   resource_group_location   = var.resource_group_location
#   virtual_network_subnet_id = module.virtual_network.subnet_integration_id
#   service_plan_name         = var.service_plan_name
#   linux_web_app_name        = var.linux_web_app_name
#   tags                      = var.default_tags
#   depends_on                = [module.virtual_network]
# }

# module "web_app_private_endpoint" {
#   source                                      = "./modules/private_endpoint"
#   resource_group_name                         = var.resource_group_name
#   resource_group_location                     = var.resource_group_location
#   private_connection_resource_id              = module.web_app.azurerm_linux_web_app_id
#   virtual_network_id                          = module.virtual_network.virtual_network_id
#   subnet_id                                   = module.virtual_network.subnet_private_id
#   private_dns_zone_id                         = azurerm_private_dns_zone.private_dns_zone_azurewebsites.id
#   private_dns_zone_name                       = azurerm_private_dns_zone.private_dns_zone_azurewebsites.name
#   private_endpoint_name                       = "pe-${var.linux_web_app_name}"
#   private_dns_zone_virtual_network_link_name  = "vnet-link-${var.linux_web_app_name}"
#   private_service_connection_name             = "psc-${var.linux_web_app_name}"
#   private_service_connection_subresource_name = "sites"

#   tags = (merge(var.default_tags, tomap({
#     type = "private_endpoint"
#     })
#   ))

#   depends_on = [module.virtual_network, module.web_app]
# }

