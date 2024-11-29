
resource "azurerm_application_gateway" "application_gateway" {
  enable_http2        = true
  location            = var.resource_group_location
  name                = "appgw-edusync-dev-001"
  resource_group_name = var.resource_group_name
  zones               = ["1", "2", "3"]
  autoscale_configuration {
    max_capacity = 10
    min_capacity = 0
  }
  backend_address_pool {
    ip_addresses = azurerm_api_management.apim.private_ip_addresses
    name         = "apim-backend"
  }
  backend_address_pool {
    name = "sync-pool"
  }
  backend_http_settings {
    cookie_based_affinity          = "Disabled"
    host_name                      = "api.cloud-devops-craft.com"
    name                           = "api-http-settings"
    port                           = 443
    probe_name                     = "pai-probe"
    protocol                       = "Https"
    request_timeout                = 20
    trusted_root_certificate_names = ["datasync-signing-root"]
  }
  backend_http_settings {
    cookie_based_affinity          = "Disabled"
    host_name                      = "developer.cloud-devops-craft.com"
    name                           = "portal-http-settings"
    port                           = 443
    probe_name                     = "portal-http-settings1a652112-ed2f-4125-b6be-ea54c1ad303_"
    protocol                       = "Https"
    request_timeout                = 20
    trusted_root_certificate_names = ["datasync-signing-root"]
  }
  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIpIPv4"
    public_ip_address_id = azurerm_public_ip.app_gateway_ip.id
  }
  frontend_ip_configuration {
    name                          = "appGwPrivateFrontendIpIPv4"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.10.3.4"
    subnet_id                     = module.virtual_network.subnet_appgw_id
  }
  frontend_port {
    name = "port_443"
    port = 443
  }
  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = module.virtual_network.subnet_appgw_id
  }
  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "api.cloud-devops-craft.com"
    name                           = "api-listener"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "app-gw-cert"
  }
  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "developer.cloud-devops-craft.com"
    name                           = "portal-listener"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "app-gw-cert"
  }
  identity {
    identity_ids = [azurerm_user_assigned_identity.user_assigned_identity.id]
    type         = "UserAssigned"
  }
  probe {
    host                = "api.cloud-devops-craft.com"
    interval            = 30
    name                = "pai-probe"
    path                = "/status-0123456789abcdef"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }
  probe {
    host                = "developer.cloud-devops-craft.com"
    interval            = 30
    name                = "portal-http-settings1a652112-ed2f-4125-b6be-ea54c1ad303_"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }
  request_routing_rule {
    http_listener_name = "api-listener"
    name               = "api-rule"
    priority           = 110
    rule_type          = "PathBasedRouting"
    url_path_map_name  = "api-rule"
  }
  request_routing_rule {
    backend_address_pool_name  = "apim-backend"
    backend_http_settings_name = "portal-http-settings"
    http_listener_name         = "portal-listener"
    name                       = "portal-rule"
    priority                   = 100
    rule_type                  = "Basic"
  }
  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }
  ssl_certificate {
    key_vault_secret_id = data.azurerm_key_vault_certificate.api_certificate.versionless_secret_id #"https://kv-shared-edusync-dev.vault.azure.net/secrets/logcorner-datasync-cert"
    name                = "app-gw-cert"
  }
  trusted_root_certificate {
    name                = "datasync-signing-root"
    key_vault_secret_id = data.azurerm_key_vault_certificate.api_certificate_root.versionless_secret_id #"https://kv-shared-edusync-dev.vault.azure.net/secrets/datasync-signin-root"
  }
  url_path_map {
    default_backend_address_pool_name  = "sync-pool"
    default_backend_http_settings_name = "api-http-settings"
    name                               = "api-rule"
    path_rule {
      backend_address_pool_name  = "apim-backend"
      backend_http_settings_name = "api-http-settings"
      name                       = "external-path"
      paths                      = ["/external/*"]
    }
  }

}

variable "public_dns_resource_group_name" {
  description = "The name of the resource group in which to create the Application Gateway."
  default     = "WORKSHOP-LOGCORNER-MICROSERVICES"
}

data "azurerm_dns_zone" "public_dns_zone" {
  name                = "cloud-devops-craft.com"
  resource_group_name = var.public_dns_resource_group_name
}


resource "azurerm_dns_a_record" "dns_a_record_api" {
  name                = "api"
  zone_name           = data.azurerm_dns_zone.public_dns_zone.name
  resource_group_name = var.public_dns_resource_group_name
  ttl                 = 3600
  records             = [azurerm_public_ip.app_gateway_ip.ip_address]
}

resource "azurerm_dns_a_record" "dns_a_record_developer" {
  name                = "developer"
  zone_name           = data.azurerm_dns_zone.public_dns_zone.name
  resource_group_name = var.public_dns_resource_group_name
  ttl                 = 3600
  records             = [azurerm_public_ip.app_gateway_ip.ip_address]
}


resource "azurerm_dns_a_record" "dns_a_record_management" {
  name                = "management"
  zone_name           = data.azurerm_dns_zone.public_dns_zone.name
  resource_group_name = var.public_dns_resource_group_name
  ttl                 = 3600
  records             = [azurerm_public_ip.app_gateway_ip.ip_address]
}



