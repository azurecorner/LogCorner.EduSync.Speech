resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags                   = (merge(var.default_tags, tomap({
    type = "resourcegroup"
    })
  ))
}

module "logcorner-vnet" {
  source                       = "./modules/vnet"
  resource_group_location      = azurerm_resource_group.resource_group.location
  resource_group_name          = azurerm_resource_group.resource_group.name
  depends_on = [ azurerm_resource_group.resource_group ]
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
   subnet_aks_id           = module.logcorner-vnet.subnet_aks_id
  msi_id = var.msi_id
  tags = (merge(var.default_tags, tomap({
    type = "aks"
    environment = var.environment
    })
  ))

  depends_on = [ module.logcorner-vnet ]
}

module "logcorner-container_registry" {
  source                      = "./modules/acr"
  resource_group_location     = azurerm_resource_group.resource_group.location
  resource_group_name         = azurerm_resource_group.resource_group.name
  acr_name                    = var.acr_name
  sku                         = var.sku
  kubernetes_cluster_identity = module.logcorner-kubernetes_service.kubernetes_cluster_identity
  tags = (merge(var.default_tags, tomap({
    type = "acr"
    environment = var.environment
    })
  ))
  depends_on = [ module.logcorner-vnet ]
}

resource "azurerm_role_assignment" "aks" {
  principal_id         =  module.logcorner-kubernetes_service.kubernetes_cluster_principal
  role_definition_name = "Network Contributor"
  scope                = module.logcorner-vnet.subnet_aks_id

  depends_on = [ module.logcorner-kubernetes_service, module.logcorner-vnet ]
}
