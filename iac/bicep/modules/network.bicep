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



@description('Specifies the name of the subnet which contains the Application Gateway for Containers.')
param containerInstanceSubnetName string

@description('Specifies the address prefix of the subnet which contains the Application Gateway for Containers.')
param containerInstanceSubnetAddressPrefix string

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
      {
        name: containerInstanceSubnetName
        properties: {
          addressPrefix: containerInstanceSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Disabled'

          delegations: [
            {
              name: 'delegationToMicrosoftContainerInstance'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
        }
      }
    ]
  }
}




output virtualNetworkObject object = virtualNetwork
output virtualNetworkName string = virtualNetwork.name
output virtualNetworkId string = virtualNetwork.id
output aks_subnet_id string = virtualNetwork.properties.subnets[0].id
output appgw_subnet_id string = virtualNetwork.properties.subnets[1].id
output privatelink_subnet_id string = virtualNetwork.properties.subnets[2].id
output applicationGatewayForContainersSubnet_id string = '${virtualNetwork.id}/subnets/${applicationGatewayForContainersSubnetName}'
output applicationGatewayForContainersSubnet_name string = virtualNetwork.properties.subnets[3].name


output containerInstanceSubnet_id string = '${virtualNetwork.id}/subnets/${containerInstanceSubnetName}'


