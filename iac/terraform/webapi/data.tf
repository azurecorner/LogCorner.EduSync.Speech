
data "azurerm_client_config" "current" {}

data "azuread_service_principal" "service_principal" {
  display_name = var.service_principal_name
}
