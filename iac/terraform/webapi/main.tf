locals {
  mssql_server_localion = "francecentral"
}

locals {
  nsg_configurations = {
    nsg_apim = {
      network_security_group_name = "nsg_apim"
      nsgrules                    = var.nsgrules_apim
      subnet_ids                  = [module.virtual_network.subnet_apim_id]
    },
    nsg_aks = {
      network_security_group_name = "nsg_aks"
      nsgrules                    = var.nsgrules_aks
      subnet_ids                  = [module.virtual_network.subnet_aks_id]
    }
    nsg-agw = {
      network_security_group_name = "nsg-agw"
      nsgrules                    = var.nsgrules_appgw
      subnet_ids                  = [module.virtual_network.subnet_appgw_id]
    }
    nsg_vm = {
      network_security_group_name = "nsg_vm"
      nsgrules                    = var.nsgrules_vm
      subnet_ids                  = [module.virtual_network.subnet_vm_id]
    }

  }
}

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
  source                  = "./modules/virtual_network"
  resource_group_location = azurerm_resource_group.resource_group.location
  resource_group_name     = azurerm_resource_group.resource_group.name
  depends_on              = [azurerm_resource_group.resource_group]
}

module "network_security_groups" {
  for_each                    = local.nsg_configurations
  source                      = "./modules/network_security_group"
  resource_group_location     = azurerm_resource_group.resource_group.location
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = each.value.network_security_group_name
  nsgrules                    = each.value.nsgrules
  subnet_ids                  = each.value.subnet_ids

  tags = merge(var.default_tags, tomap({
    type        = "nsg"
    environment = var.environment
  }))

  depends_on = [module.virtual_network]
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

# TODO ADD ACR PULL ROLE

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

module "sql_server" {
  source                                                      = "./modules/database"
  resource_group_name                                         = var.resource_group_name
  resource_group_location                                     = local.mssql_server_localion
  mssql_server_name                                           = var.mssql_server_name
  mssql_server_version                                        = var.mssql_server_version
  mssql_server_firewall_rules                                 = var.mssql_server_firewall_rules
  mssql_database_sku_name                                     = var.mssql_database_sku_name
  mssql_database_long_term_retention_policy_monthly_retention = var.mssql_database_long_term_retention_policy_monthly_retention
  mssql_database_long_term_retention_policy_week_of_year      = var.mssql_database_long_term_retention_policy_week_of_year
  mssql_database_read_scale                                   = var.mssql_database_read_scale

  mssql_database_storage_account_type = var.mssql_database_storage_account_type
  mssql_database_zone_redundant       = var.mssql_database_zone_redundant

  tags = (merge(var.default_tags, tomap({
    type = "key_vault"
    })
  ))
  key_vault_id   = module.key_vault.key_vault_id
  sql_db_name    = var.sql_db_name
  admin_username = var.admin_username
  depends_on     = [module.virtual_network, module.key_vault]
}


resource "azurerm_public_ip" "app_gateway_ip" {
  name                = "app_gateway_ip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = ["1", "2", "3"]
  depends_on          = [azurerm_resource_group.resource_group]
}

# data "azurerm_key_vault_certificate" "certificate" {
#   name         = "logcorner-datasync-cert"
#   key_vault_id = module.key_vault.key_vault_id

#   depends_on = [module.key_vault]
# }

# module "application_gateway" {
#   source                    = "./modules/application_gateway"
#   resource_group_name       = var.resource_group_name
#   resource_group_location   = var.resource_group_location
#   virtual_network_subnet_id = module.virtual_network.subnet_appgw_id
#   key_vault_secret_id       = data.azurerm_key_vault_certificate.certificate.secret_id
#   user_assigned_identity_id = azurerm_user_assigned_identity.user_assigned_identity.id
#   public_ip_address_id      = azurerm_public_ip.app_gateway_ip.id


#   application_gateway_name = var.application_gateway_name

#   application_gateway_backend_pool_name = var.application_gateway_backend_pool_name

#   application_gateway_backend_settings_name = var.application_gateway_backend_settings_name

#   application_gateway_probe_name = var.application_gateway_probe_name

#   application_gateway_https_frontend_port = var.application_gateway_https_frontend_port

#   frontend_ip_configuration_name = var.frontend_ip_configuration_name

#   https_listener_name = var.https_listener_name

#   ssl_certificate_name = var.ssl_certificate_name

#   gateway_ip_configuration_name = var.gateway_ip_configuration_name

#   backend_address_pool_fqdn =  var.backend_address_pool_fqdn
#   tags = (merge(var.default_tags, tomap({
#     type = "application_gateway"
#     })
#   ))

#   depends_on = [azurerm_user_assigned_identity.user_assigned_identity, module.key_vault]
# }




# module "virtual_machine" {
#   source = "./modules/virtual_machine"
#   count  = 1 // number of virtual machines

#   resource_group_name     = var.resource_group_name
#   resource_group_location = var.resource_group_location
#   subnet_id               = module.virtual_network.subnet_vm_id
#   tags = (merge(var.default_tags, tomap({
#     type = "virtual_machine"
#     })
#   ))
#   public_ip_name              = "VM-DATASYNC-${var.public_ip_name}-${format("%03d", count.index + 1)}"
#   network_security_group_name = "VM-DATASYNC-${var.network_security_group_name}-${format("%03d", count.index + 1)}"
#   network_interface_name      = "VM-DATASYNC-${var.network_interface_name}-${format("%03d", count.index + 1)}"
#   virtual_machine_name        = "VM-DATASYNC-${var.virtual_machine_name}-${format("%03d", count.index + 1)}"
#   computer_name               = "${var.virtual_machine_name}-${format("%03d", count.index + 1)}"
#   username                    = var.vm_username
#   depends_on                  = [module.virtual_network]
# }


resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = 30
  depends_on          = [azurerm_resource_group.resource_group]
}

resource "azurerm_application_insights" "application_insights" {
  name                = var.application_insights_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
  application_type    = "web"
  depends_on          = [azurerm_resource_group.resource_group, azurerm_log_analytics_workspace.log_analytics_workspace]
}