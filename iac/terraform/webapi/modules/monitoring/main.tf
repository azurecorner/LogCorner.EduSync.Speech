
resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  for_each                   = var.log_categories_retention
  name                       = var.diagnostics_settings_name
  target_resource_id         = var.resource_id
  log_analytics_workspace_id = var.law_id

  enabled_log {
    category = each.key
  }

  metric {
    category = "AllMetrics"
  
  }
  lifecycle {
    ignore_changes = [metric]
  }
}



