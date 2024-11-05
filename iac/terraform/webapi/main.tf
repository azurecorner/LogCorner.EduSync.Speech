

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = (merge(var.default_tags, tomap({
    type = "resourcegroup"
    })
  ))
}

resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  location            = var.resource_group_location
  name                = var.user_assigned_identity_name
  resource_group_name = var.resource_group_name

  tags = (merge(var.default_tags, tomap({
    type = "user_assigned_identity"
    })
  ))

  depends_on = [azurerm_resource_group.resource_group]
}

module "virtual_network" {
  source                  = "./modules/vnet"
  resource_group_location = azurerm_resource_group.resource_group.location
  resource_group_name     = azurerm_resource_group.resource_group.name
  depends_on              = [azurerm_resource_group.resource_group]
}



module "logcorner-kubernetes_service" {
  source                  = "./modules/aks"
  resource_group_location = azurerm_resource_group.resource_group.location
  resource_group_name     = azurerm_resource_group.resource_group.name
  aks_name                = var.aks_name
  vm_size                 = var.vm_size
  node_count              = var.node_count
  username                = var.username
  load_balancer_sku       = var.load_balancer_sku
  subnet_aks_id           = module.virtual_network.subnet_aks_id
  msi_id                  = var.msi_id
  tags = (merge(var.default_tags, tomap({
    type        = "aks"
    environment = var.environment
    })
  ))

  depends_on = [module.virtual_network]
}

module "logcorner-container_registry" {
  source                      = "./modules/acr"
  resource_group_location     = azurerm_resource_group.resource_group.location
  resource_group_name         = azurerm_resource_group.resource_group.name
  acr_name                    = var.acr_name
  sku                         = var.sku
  kubernetes_cluster_identity = module.logcorner-kubernetes_service.kubernetes_cluster_identity
  tags = (merge(var.default_tags, tomap({
    type        = "acr"
    environment = var.environment
    })
  ))
  depends_on = [module.virtual_network]
}

resource "azurerm_role_assignment" "aks" {
  principal_id         = module.logcorner-kubernetes_service.kubernetes_cluster_principal
  role_definition_name = "Network Contributor"
  scope                = module.virtual_network.subnet_aks_id

  depends_on = [module.logcorner-kubernetes_service, module.virtual_network]
}


module "key_vault" {
  source                      = "./modules/keyvault"
  resource_group_name         = var.resource_group_name
  resource_group_location     = var.resource_group_location
  user_assigned_identity_id   = azurerm_user_assigned_identity.user_assigned_identity.principal_id
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  key_vault_name              = var.key_vault_name
  key_vault_sku               = var.key_vault_sku
  service_principal_name      = var.service_principal_name
  service_principal_object_id = data.azuread_service_principal.service_principal.object_id
  tags = (merge(var.default_tags, tomap({
    type = "key_vault"
    })
  ))

  depends_on = [azurerm_user_assigned_identity.user_assigned_identity, module.virtual_network]
}

# module "sql_server" {
#   source                  = "./modules/sql_database"
#   resource_group_name     = var.resource_group_name
#   resource_group_location = var.resource_group_location
#   mssql_server_name       = var.mssql_server_name
#   mssql_server_version    = var.mssql_server_version

#   mssql_database_sku_name                                     = var.mssql_database_sku_name
#   mssql_database_long_term_retention_policy_monthly_retention = var.mssql_database_long_term_retention_policy_monthly_retention
#   mssql_database_long_term_retention_policy_week_of_year      = var.mssql_database_long_term_retention_policy_week_of_year
#   mssql_database_read_scale                                   = var.mssql_database_read_scale

#   mssql_database_storage_account_type = var.mssql_database_storage_account_type
#   mssql_database_zone_redundant       = var.mssql_database_zone_redundant

#   tags           = var.tags
#   key_vault_id   = data.azurerm_key_vault.key_vault.id
#   sql_db_name    = var.sql_db_name
#   admin_username = var.admin_username
#   depends_on     = [module.virtual_network, module.key_vault_private_endpoint]
# }