
resource "azurerm_service_plan" "appserviceplan" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "webapp" {
  name                      = var.linux_web_app_name
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  service_plan_id           = azurerm_service_plan.appserviceplan.id
  https_only                = true
  virtual_network_subnet_id = var.virtual_network_subnet_id
  identity {
    type = "SystemAssigned"
  }
  site_config {

    application_stack {
      dotnet_version = "9.0"
    }
  }
  tags = (merge(var.tags, tomap({
    type = "function_app"
    })
  ))
}