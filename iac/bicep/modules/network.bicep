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

@description('Specifies the name of the subnet which contains the Application Gateway for Containers.')
param applicationGatewayForContainersSubnetName string

@description('Specifies the address prefix of the subnet which contains the Application Gateway for Containers.')
param applicationGatewayForContainersSubnetAddressPrefix string

param appgw_subnet_addressPrefix string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: virtualNetworkAddressSpace
    }
    subnets: [
      {
        name: aks_subnet_name
        properties: {
          addressPrefix: aks_subnet_addressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: appgw_subnet_name
        properties: {
          addressPrefix: appgw_subnet_addressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: privatelink_subnet_name
        properties: {
          addressPrefix: privatelink_subnet_addressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: applicationGatewayForContainersSubnetName
        properties: {
          addressPrefix: applicationGatewayForContainersSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Disabled'

          delegations: [
            {
              name: 'delegationToMicrosoftAppGatewayForContainers'
              properties: {
                serviceName: 'Microsoft.ServiceNetworking/trafficControllers'
              }
            }
          ]
        }
      }
    ]
  }
}



// resource aks_subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
//   parent: virtualNetwork
//   name: aks_subnet_name
//   properties: {
//     addressPrefix: aks_subnet_addressPrefix
//     privateEndpointNetworkPolicies: 'Enabled'
//        privateLinkServiceNetworkPolicies: 'Disabled'
//   }
// }

// resource appgw_subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
//   parent: virtualNetwork
//   name: appgw_subnet_name
//   properties: {
//     addressPrefix: appgw_subnet_addressPrefix
//     privateEndpointNetworkPolicies: 'Enabled'
//        privateLinkServiceNetworkPolicies: 'Disabled'
//   }
// }

// resource privatelink_subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
//   parent: virtualNetwork
//   name: privatelink_subnet_name
//   properties: {
//     addressPrefix: privatelink_subnet_addressPrefix
//     privateEndpointNetworkPolicies: 'Enabled'
//        privateLinkServiceNetworkPolicies: 'Disabled'
//   }
// }

// resource applicationGatewayForContainersSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
//   parent: virtualNetwork
//   name: applicationGatewayForContainersSubnetName
//   properties: {
//     addressPrefix: applicationGatewayForContainersSubnetAddressPrefix
//     privateEndpointNetworkPolicies: 'Enabled'
//        privateLinkServiceNetworkPolicies: 'Disabled'
//   }
// }

// output virtualNetworkObject object = virtualNetwork
// output virtualNetworkName string = virtualNetwork.name
// output virtualNetworkId string = virtualNetwork.id
// output aks_subnet_id string = aks_subnet.id
// output appgw_subnet_id string = appgw_subnet.id
// output applicationGatewayForContainersSubnet_id string = applicationGatewayForContainersSubnet.id
// output applicationGatewayForContainersSubnet_name string = applicationGatewayForContainersSubnet.name
// output privatelink_subnet_id string = privatelink_subnet.id


output virtualNetworkObject object = virtualNetwork
output virtualNetworkName string = virtualNetwork.name
output virtualNetworkId string = virtualNetwork.id
output aks_subnet_id string = virtualNetwork.properties.subnets[0].id
output appgw_subnet_id string = virtualNetwork.properties.subnets[1].id
output privatelink_subnet_id string = virtualNetwork.properties.subnets[2].id
output applicationGatewayForContainersSubnet_id string = virtualNetwork.properties.subnets[3].id
output applicationGatewayForContainersSubnet_name string = virtualNetwork.properties.subnets[3].name


