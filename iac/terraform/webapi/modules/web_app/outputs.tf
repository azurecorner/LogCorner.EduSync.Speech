
output "azurerm_linux_web_app_id" {
  description = "value"
  value       = azurerm_linux_web_app.webapp.id
}

output "linux_web_app_default_hostname" {
  description = "value"
  value       = azurerm_linux_web_app.webapp.default_hostname
}