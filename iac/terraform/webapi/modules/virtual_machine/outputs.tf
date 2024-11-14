output "private_ip_address" {
  value     = azurerm_windows_virtual_machine.windows_virtual_machine.private_ip_address
  sensitive = true
}

output "linux_virtual_machine_name" {
  value = azurerm_windows_virtual_machine.windows_virtual_machine.name
}