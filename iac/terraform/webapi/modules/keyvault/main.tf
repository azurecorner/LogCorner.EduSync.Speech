resource "azurerm_key_vault" "key_vault" {
  name                       = var.key_vault_name
  location                   = var.resource_group_location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = var.key_vault_sku
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  tags = var.tags
}


resource "azurerm_key_vault_access_policy" "vault_access_policy_managed_id" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = var.tenant_id

  certificate_permissions = [
    "Get", "List"
  ]

  object_id = var.user_assigned_identity_id
  secret_permissions = [
    "Get", "List", "Set", "Recover"
  ]

}

resource "azurerm_key_vault_access_policy" "vault_access_policy_principal" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = var.tenant_id
  object_id    = var.service_principal_object_id

  certificate_permissions = [
    "Get", "List"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Recover", "Delete", "Purge"
  ]

}


resource "azurerm_key_vault_access_policy" "vault_access_policy_me" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = var.tenant_id
  object_id    = "7abf4c5b-9638-4ec4-b830-ede0a8031b25"

  certificate_permissions = [
    "Get", "List"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Recover", "Delete", "Purge"
  ]


}