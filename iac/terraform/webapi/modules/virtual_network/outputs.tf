
output "virtual_network_id" {
  value = azurerm_virtual_network.apim-aks.id

}

output "subnet_aks_id" {
  description = "The name of the azure kubernetes service cluster"
  value       = azurerm_subnet.aks.id
}
output "subnet_apim_id" {
  value = azurerm_subnet.apim.id
}

output "subnet_appgw_id" {
  value = azurerm_subnet.appgw.id
}

output "subnet_vm_id" {
  value = azurerm_subnet.vm.id
}

output "subnet_private_id" {
  value = azurerm_subnet.private.id
}

output "subnet_integration_id" {
  value = azurerm_subnet.integration.id
}

output "subnet_bastion_id" {
  value = azurerm_subnet.bastion_subnet.id
}