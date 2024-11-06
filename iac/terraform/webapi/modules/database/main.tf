resource "random_password" "admin_password" {
  count       = 1
  length      = 20
  special     = true
  min_numeric = 1
  min_upper   = 1
  min_lower   = 1
  min_special = 1
}

resource "azurerm_mssql_server" "mssql_server" {
  name                          = var.mssql_server_name
  resource_group_name           = var.resource_group_name
  location                      = var.resource_group_location
  administrator_login           = var.admin_username
  administrator_login_password  = random_password.admin_password[0].result
  version                       = var.mssql_server_version
  public_network_access_enabled = true


  identity {
    type = "SystemAssigned"
  }

  tags = (merge(var.tags, tomap({
    type = "mssql_server"
    })
  ))

  depends_on = [random_password.admin_password]
}

resource "azurerm_mssql_database" "mssql_database" {
  name                 = var.sql_db_name
  server_id            = azurerm_mssql_server.mssql_server.id
  read_scale           = var.mssql_database_read_scale
  sku_name             = var.mssql_database_sku_name
  storage_account_type = var.mssql_database_storage_account_type
  zone_redundant       = var.mssql_database_zone_redundant

  long_term_retention_policy {
    monthly_retention = var.mssql_database_long_term_retention_policy_monthly_retention
    week_of_year      = var.mssql_database_long_term_retention_policy_week_of_year
  }
  short_term_retention_policy {
    retention_days = 10

  }

  tags = (merge(var.tags, tomap({
    type = "mssql_database"
    })
  ))

  depends_on = [azurerm_mssql_server.mssql_server, azurerm_key_vault_secret.key_vault_secret]
}

resource "azurerm_key_vault_secret" "key_vault_secret" {
  key_vault_id = var.key_vault_id
  name         = "SqlServer--Password"
  value        = random_password.admin_password[0].result

  depends_on = [random_password.admin_password]
}


resource "azurerm_mssql_firewall_rule" "mssql_firewall_rule" {
  for_each         = var.mssql_server_firewall_rules
  name             = "FirewallRule-${each.key}"
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}