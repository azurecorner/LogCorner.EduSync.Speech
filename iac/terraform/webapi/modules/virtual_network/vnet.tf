
resource "azurerm_virtual_network" "apim-aks" {
  name                = "edusync-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.apim-aks.name
  address_prefixes     = ["10.10.1.0/24"]
  depends_on           = [azurerm_virtual_network.apim-aks]
}


resource "azurerm_subnet" "apim" {
  name                 = "apim-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.apim-aks.name
  address_prefixes     = ["10.10.2.0/24"]
  depends_on           = [azurerm_virtual_network.apim-aks]
}

resource "azurerm_subnet" "appgw" {
  name                 = "appGw-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.apim-aks.name
  address_prefixes     = ["10.10.3.0/24"]
  depends_on           = [azurerm_virtual_network.apim-aks]
}

resource "azurerm_subnet" "vm" {
  name                 = "vm-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.apim-aks.name
  address_prefixes     = ["10.10.4.0/24"]
  depends_on           = [azurerm_virtual_network.apim-aks]
}


resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.apim-aks.name
  address_prefixes     = ["10.10.5.0/24"]
  depends_on           = [azurerm_virtual_network.apim-aks]
}


resource "azurerm_subnet" "integration" {
  name                 = "integration-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.apim-aks.name
  address_prefixes     = ["10.10.6.0/24"]
  delegation {
    name = "delegation"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      name    = "Microsoft.Web/serverFarms"
    }
  }

  depends_on = [azurerm_virtual_network.apim-aks]
}


