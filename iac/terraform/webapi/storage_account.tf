# # Create storage account for boot diagnostics
# resource "azurerm_storage_account" "storage_account" {
#   name                     = "datasyncst001"
#   location                 = var.resource_group_location
#   resource_group_name      = var.resource_group_name
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }