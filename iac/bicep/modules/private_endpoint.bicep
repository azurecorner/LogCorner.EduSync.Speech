
@description('The Azure Region to deploy the resources into')
param location string 
param privateEndpointName string
param privateDnsZoneName string
param endpointDnsGroupName string 
param subnetId string
param privateLinkServiceId string
param privateLinkConnexionServiceName string
param groupIds array 

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnexionServiceName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: groupIds
        }
      }
    ]
  }
 }

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
    name: privateDnsZoneName
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: endpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

