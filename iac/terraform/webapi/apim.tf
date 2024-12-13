# https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-integrate-internal-vnet-appgateway
# https://learn.microsoft.com/en-us/azure/architecture/solution-ideas/articles/mutual-tls-deploy-aks-api-management
# Integrate Azure API Management (Internal Mode) with Application Gateway =>  https://youtu.be/8asofOkNaIU?si=9-LURyscMBz0PjC5  and https://youtu.be/JWcMsYBC34I?si=on0ynxy-N7KL4h1C

variable "swagger_file" {
  default = "C:\\Users\\LEYE-GORA\\source\\repos\\EVENT DRIVEN ARCHITECTURE- FULL MICROSOFT\\LogCorner.EduSync.Speech.Command\\src\\LogCorner.EduSync.Speech.Presentation\\LogCorner-EduSync-Speech-Presentation-OpenApi.json"
}
resource "azurerm_api_management" "apim" {
  name                = var.api_management_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email

  //sku_name = var.sku_name
  sku_name = "Developer_1" # Ensure this is correct

  virtual_network_type = "Internal"

  virtual_network_configuration {
    subnet_id = module.virtual_network.subnet_apim_id
  }

  identity {
    type = "SystemAssigned"
  }
  depends_on = [module.network_security_groups]

}


#Define the API within Azure API Management
resource "azurerm_api_management_api" "query-http-api" {
  name                = "query-http-api"
  resource_group_name = azurerm_api_management.apim.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  revision            = "2"
  display_name        = "Query HTTP API"
  path                = "external" # Path under API Management
  protocols           = ["https", "http"]
  service_url         = "http://ingress.cloud-devops-craft.com/aks-command-api" # Base URL of the backend service
  
  subscription_required = false
  import {
    content_format = "openapi+json"
    content_value  = file(var.swagger_file)
  }

}
/* 
# Define the API operation for the WeatherForecast endpoint
resource "azurerm_api_management_api_operation" "api_management_api_operation_query" {
  operation_id        = "getWeatherForecast"
  api_name            = azurerm_api_management_api.query-http-api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_api_management.apim.resource_group_name
  display_name        = "Get Weather Forecast"
  method              = "GET"
  url_template        = "/api/WeatherForecast" # Endpoint path relative to the base URL
  response {
    status_code = 200
    description = "Successful response"
    representation {
      content_type = "application/json"
    }
  }
}


resource "azurerm_api_management_api_operation" "api_management_api_operation_query_by_id" {
  operation_id        = "get-weatherForecast-by-id"
  api_name            = azurerm_api_management_api.query-http-api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name
  display_name        = "Get WeatherForecast by Id"
  method              = "GET"
  url_template        = "/api/WeatherForecast/{id}"
  description         = "Get WeatherForecast by Id."

  template_parameter {
    name     = "id"
    type     = "number"
    required = true
  }

  response {
    status_code = 200
  }
} */


/* # Define the API within Azure API Management
resource "azurerm_api_management_api" "command-http-api" {
  name                = "command-http-api"
  resource_group_name = azurerm_api_management.apim.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  revision            = "2"
  display_name        = "Command HTTP API"
  path                = "internal" # The base path for the API
  protocols           = ["https", "http"]
  service_url         = "http://ingress.cloud-devops-craft.com/aks-command-api" # Base backend service URL
}
# Define the API operation for the POST /api/speech endpoint
resource "azurerm_api_management_api_operation" "command-http-api-operation_post" {
  operation_id        = "createSpeech"
  api_name            = azurerm_api_management_api.command-http-api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_api_management.apim.resource_group_name
  display_name        = "Create Speech"
  method              = "POST"
  url_template        = "/api/speech" # Endpoint path relative to the base service URL

  request {
    representation {
      content_type = "application/json"
    }
  }

  response {
    status_code = 200
    description = "Successful response"
    representation {
      content_type = "application/json"
    }
  }
}

resource "azurerm_api_management_api_operation" "command-http-api-operation_put" {
  operation_id        = "updateSpeech"
  api_name            = azurerm_api_management_api.command-http-api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_api_management.apim.resource_group_name
  display_name        = "Update Speech"
  method              = "PUT"
  url_template        = "/api/speech" # Endpoint path relative to the base service URL
  request {
    representation {
      content_type = "application/json"
    }
  }
  response {
    status_code = 200
    description = "Successful response"
    representation {
      content_type = "application/json"
    }
  }
}


resource "azurerm_api_management_api_operation" "command-http-api-operation_delete" {
  operation_id        = "deleteSpeech"
  api_name            = azurerm_api_management_api.command-http-api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_api_management.apim.resource_group_name
  display_name        = "Delete Speech"
  method              = "DELETE"
  url_template        = "/api/speech" # Endpoint path relative to the base service URL

  request {
    representation {
      content_type = "application/json"
    }
  }

  response {
    status_code = 200
    description = "Successful response"
    representation {
      content_type = "application/json"
    }
  }
} */


resource "azurerm_api_management_product" "product" {
  product_id            = "speech-microservice-http-api"
  api_management_name   = azurerm_api_management.apim.name
  resource_group_name   = var.resource_group_name
  display_name          = "The Speech Micro Service  HTTP API Product"
  subscription_required = false
  approval_required     = false
  published             = true
}

# resource "azurerm_api_management_product_api" "product_query_http_api" {
#   api_name            = azurerm_api_management_api.query-http-api.name
#   product_id          = azurerm_api_management_product.product.product_id
#   api_management_name = azurerm_api_management.apim.name
#   resource_group_name = var.resource_group_name
# }

/* 
resource "azurerm_api_management_product_api" "product_command_http_api" {
  api_name            = azurerm_api_management_api.command-http-api.name
  product_id          = azurerm_api_management_product.product.product_id
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name
} */

# custom domain
resource "azurerm_api_management_custom_domain" "api_management_custom_domain" {
  api_management_id = azurerm_api_management.apim.id
  gateway {
    host_name    = "api.cloud-devops-craft.com"
    key_vault_id = data.azurerm_key_vault_certificate.api_certificate.versionless_secret_id
  }
  developer_portal {
    host_name    = "developer.cloud-devops-craft.com"
    key_vault_id = data.azurerm_key_vault_certificate.api_certificate.versionless_secret_id
  }
  management {
    host_name    = "management.cloud-devops-craft.com"
    key_vault_id = data.azurerm_key_vault_certificate.api_certificate.versionless_secret_id
  }

  depends_on = [azurerm_key_vault_access_policy.apim_key_vault_access_policy]
}

resource "azurerm_key_vault_access_policy" "apim_key_vault_access_policy" {
  key_vault_id = module.key_vault.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_api_management.apim.identity[0].principal_id

  secret_permissions = [
    "Get",
  ]

  certificate_permissions = [
    "Get",
  ]

  depends_on = [azurerm_api_management.apim]
}

resource "azurerm_private_dns_a_record" "private_dns_a_record_api" {
  name                = "api"
  zone_name           = azurerm_private_dns_zone.api_private_dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  records             = azurerm_api_management.apim.private_ip_addresses
}


resource "azurerm_private_dns_a_record" "private_dns_a_record_management" {
  name                = "management"
  zone_name           = azurerm_private_dns_zone.api_private_dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  records             = azurerm_api_management.apim.private_ip_addresses
}

resource "azurerm_private_dns_a_record" "private_dns_a_record_portal" {
  name                = "developer"
  zone_name           = azurerm_private_dns_zone.api_private_dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  records             = azurerm_api_management.apim.private_ip_addresses
}


resource "azurerm_api_management_logger" "api_management_logger" {
  name                = "example-apimlogger"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name

  application_insights {
    instrumentation_key = azurerm_application_insights.application_insights.instrumentation_key
  }
}

resource "azurerm_api_management_diagnostic" "api_management_diagnostic" {
  identifier               = "applicationinsights"
  resource_group_name      = var.resource_group_name
  api_management_name      = azurerm_api_management.apim.name
  api_management_logger_id = azurerm_api_management_logger.api_management_logger.id

  sampling_percentage       = 5.0
  always_log_errors         = true
  log_client_ip             = true
  verbosity                 = "verbose"
  http_correlation_protocol = "W3C"

  frontend_request {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "accept",
      "origin",
    ]
  }

  frontend_response {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "content-length",
      "origin",
    ]
  }

  backend_request {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "accept",
      "origin",
    ]
  }

  backend_response {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "content-length",
      "origin",
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting_apim" {
  name               = "apim-diagnostic-settings"
  target_resource_id = azurerm_api_management.apim.id

  # Destination for logs and metrics
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id

  # Log settings

  enabled_log {
    category = "GatewayLogs"
   
  }
#   enabled_log {
#     category = "developerportal"
#   }

#  enabled_log {
#     category = "websockets"
#  }
  # enabled_log {
  #   category = "DeveloperPortalLogs"
   
  # }


  # enabled_log {
  #   category = "AuditEvent"
  # }

  metric {
    category = "AllMetrics"
  }

  # Metric settings
  # metric {
  #   category = "AllMetrics"
  #   enabled  = true
  # }
}



output "apim_principal_id" {
  value = azurerm_api_management.apim.identity[0].principal_id
}

output "api_management_private_ip_addresses" {
  description = "The Private IP addresses of the API Management Service"
  value       = azurerm_api_management.apim.private_ip_addresses
}