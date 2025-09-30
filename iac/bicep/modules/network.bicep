param location string

@description('Virtual network resource name.')
param virtualNetworkName string

@description('Virtual network resource Address Space.')
param virtualNetworkAddressSpace array

param aks_subnet_name string


param aks_subnet_addressPrefix string

param appgw_subnet_name string

param privatelink_subnet_name string
param privatelink_subnet_addressPrefix string


param appgw_subnet_addressPrefix string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: virtualNetworkAddressSpace
    }
  }
}


resource aks_subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: virtualNetwork
  name: aks_subnet_name
  properties: {
    addressPrefix: aks_subnet_addressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
       privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

resource appgw_subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: virtualNetwork
  name: appgw_subnet_name
  properties: {
    addressPrefix: appgw_subnet_addressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
       privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

resource privatelink_subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: virtualNetwork
  name: privatelink_subnet_name
  properties: {
    addressPrefix: privatelink_subnet_addressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
       privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

output virtualNetworkObject object = virtualNetwork
output virtualNetworkName string = virtualNetwork.name
output virtualNetworkId string = virtualNetwork.id
output aks_subnet_id string = aks_subnet.id
output appgw_subnet_id string = appgw_subnet.id

output privatelink_subnet_id string = privatelink_subnet.id
