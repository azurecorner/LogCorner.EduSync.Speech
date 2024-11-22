
data "azurerm_client_config" "current" {}

data "azuread_service_principal" "service_principal" {
  display_name = var.service_principal_name
}


# data "azurerm_key_vault_certificate" "api_certificate" {
#   name         = "api-management-cert"
#   key_vault_id = module.key_vault.key_vault_id

#   depends_on = [module.key_vault]
# }