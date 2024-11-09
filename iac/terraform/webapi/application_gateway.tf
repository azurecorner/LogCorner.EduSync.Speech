
# variable "resource_group_name" {
#   description = "Location of the resource group."
#   type        = string
# }

# variable "resource_group_location" {
#   description = "Location of the resource group."
#   type        = string
# }

# variable "virtual_network_subnet_id" {
#   description = "Id of the web application subnet"
#   type        = string
# }

# variable "tags" {
#   type = map(string)
# }

# variable "key_vault_secret_id" {
#   description = "Id  of the secret of the application gateway in the keyvault."
#   type        = string
# }

# variable "user_assigned_identity_id" {
#   description = "id of the user assigned managed identity."
#   type        = string
# }
# variable "functionapp_backend_address_pool_fqdn" {

# }

# variable "public_ip_address_id" {

# }
# variable "application_gateway_name" {

# }

# variable "application_gateway_backend_pool_name" {

# }

# variable "application_gateway_backend_settings_name" {

# }

# variable "application_gateway_probe_name" {

# }


# variable "application_gateway_https_frontend_port" {

# }
# variable "frontend_ip_configuration_name" {

# }

# variable "https_listener_name" {

# }

# variable "ssl_certificate_name" {

# }

# variable "gateway_ip_configuration_name" {

# }

# resource "azurerm_application_gateway" "application_gateway" {
#   location            = var.resource_group_location
#   name                = var.application_gateway_name
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
#   autoscale_configuration {
#     max_capacity = 2
#     min_capacity = 0
#   }
#   backend_address_pool {
#     fqdns = [var.functionapp_backend_address_pool_fqdn]
#     name  = var.application_gateway_backend_pool_name
#   }
#   backend_http_settings {
#     affinity_cookie_name                = "ApplicationGatewayAffinity"
#     cookie_based_affinity               = "Disabled"
#     name                                = var.application_gateway_backend_settings_name
#     pick_host_name_from_backend_address = true
#     port                                = 443
#     probe_name                          = var.application_gateway_probe_name
#     protocol                            = "Https"
#   }
#   frontend_ip_configuration {
#     name                 = var.frontend_ip_configuration_name
#     public_ip_address_id = var.public_ip_address_id
#   }

#   frontend_port {
#     name = var.application_gateway_https_frontend_port
#     port = 443
#   }
#   gateway_ip_configuration {
#     name      = var.gateway_ip_configuration_name
#     subnet_id = var.virtual_network_subnet_id
#   }
#   http_listener {
#     frontend_ip_configuration_name = var.frontend_ip_configuration_name
#     frontend_port_name             = var.application_gateway_https_frontend_port
#     name                           = var.https_listener_name
#     protocol                       = "Https"
#     ssl_certificate_name           = var.ssl_certificate_name
#   }
#   identity {
#     identity_ids = [var.user_assigned_identity_id]
#     type         = "UserAssigned"
#   }
#   probe {
#     interval                                  = 60
#     name                                      = var.application_gateway_probe_name
#     path                                      = "/"
#     pick_host_name_from_backend_http_settings = true
#     protocol                                  = "Https"
#     timeout                                   = 60
#     unhealthy_threshold                       = 3
#     match {
#       status_code = ["200-399"]
#     }
#   }
#   request_routing_rule {
#     backend_address_pool_name  = var.application_gateway_backend_pool_name
#     backend_http_settings_name = var.application_gateway_backend_settings_name
#     http_listener_name         = var.https_listener_name
#     name                       = "https-rule"
#     priority                   = 200
#     rule_type                  = "Basic"
#   }
#   sku {
#     name = "WAF_v2"
#     tier = "WAF_v2"
#   }
#   ssl_certificate {
#     key_vault_secret_id = var.key_vault_secret_id
#     name                = var.ssl_certificate_name
#   }

#   waf_configuration {
#     enabled              = true
#     file_upload_limit_mb = 750
#     firewall_mode        = "Prevention"
#     rule_set_version     = "3.1"
#   }
# }
