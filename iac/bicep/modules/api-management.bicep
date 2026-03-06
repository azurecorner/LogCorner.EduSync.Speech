param location string
param apiManagementName string
param selfHostedGatewayName string
@description('The resource name')

param keyVaultName string 
param apimSubnetId string

param userAssignedIdentityName string

@description('A custom domain name to be used for the API Management service.')
param apiManagementCustomDnsName string

@description('A custom domain name for the API Management service developer portal (e.g., portal.consoto.com). ')
param apiManagementPortalCustomHostname string

@description('A custom domain name for the API Management service gateway/proxy endpoint (e.g., api.consoto.com).')
param apiManagementProxyCustomHostname string

@description('A custom domain name for the API Management service management portal (e.g., management.consoto.com).')
param apiManagementManagementCustomHostname string

param hubVirtualNetworkId string
param virtualNetworkId string

param certificateName string 

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' existing = {
  name: userAssignedIdentityName

}


resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource certificate 'Microsoft.KeyVault/vaults/secrets@2024-11-01' existing = {
  parent: keyVault
  name: certificateName
}


// API Management Instance
resource apiManagement 'Microsoft.ApiManagement/service@2025-03-01-preview' = {
  name: apiManagementName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  sku: {
    name: 'Developer'
    capacity: 1
  }
  properties: {
    publisherName: 'Contoso'
    publisherEmail: 'leyegora@gmail.com'
    virtualNetworkType: 'Internal'
    virtualNetworkConfiguration: {
      subnetResourceId: apimSubnetId
    }
    hostnameConfigurations: [
      {
        type: 'DeveloperPortal'
        hostName: apiManagementPortalCustomHostname
        keyVaultId:  certificate.properties.secretUri 
        identityClientId: userAssignedIdentity.properties.clientId
        
      }
      {
        type: 'Proxy'
        hostName: apiManagementProxyCustomHostname

          keyVaultId:  certificate.properties.secretUri 
        identityClientId: userAssignedIdentity.properties.clientId
        defaultSslBinding: true
      }
      {
        type: 'Management'
        hostName: apiManagementManagementCustomHostname
        keyVaultId:  certificate.properties.secretUri 
        identityClientId: userAssignedIdentity.properties.clientId

      }
    ]
  }
}

// Gateway
 resource selfHostedGateway 'Microsoft.ApiManagement/service/gateways@2024-05-01' = {
  name: selfHostedGatewayName
  parent: apiManagement
  properties:{
    description: 'Self-hosted API Gateway on Azure Kubernetes Service'
    locationData: {
      name: 'Azure Kubernetes Service'
      countryOrRegion: 'Cloud'
    }
  }
} 

 // ---- Private DNS Zone ----
 resource apiManagementPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'azure-api.net' // matches the APIM internal hostname domain
  location: 'global'

  resource configurationRecord 'A' = {
    name: '${apiManagementName}.configuration' // relative name
    properties: {
      ttl: 3600
      aRecords: [
        {
          ipv4Address: apiManagement.properties.privateIPAddresses[0]
        }
      ]
    }
  }

  resource link 'virtualNetworkLinks' = {
    name: 'privateDnsZoneLink'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetworkId
      }
    }
  }


  resource link_hub 'virtualNetworkLinks' = {
    name: 'privateDnsZoneLink-hub'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: hubVirtualNetworkId
      }
    }
  }
}


 // ---- Private DNS Zone ----
 resource apiManagementCustomDnsPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: apiManagementCustomDnsName
  location: 'global'

  resource apiRecord 'A' = {
    name: 'api'
    properties: {
      ttl: 3600
      aRecords: [
        {
          ipv4Address: apiManagement.properties.privateIPAddresses[0]
        }
      ]
    }
  }

  resource managementRecord 'A' = {
    name: 'management'
    properties: {
      ttl: 3600
      aRecords: [
        {
          ipv4Address: apiManagement.properties.privateIPAddresses[0]
        }
      ]
    }
  }

  resource portalRecord 'A' = {
    name: 'portal'
    properties: {
      ttl: 3600
      aRecords: [
        {
          ipv4Address: apiManagement.properties.privateIPAddresses[0]
        }
      ]
    }
  } 


  

  resource link 'virtualNetworkLinks' = {
    name: 'privateDnsZoneLink'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetworkId
      }
    }
  }


  resource link_hub 'virtualNetworkLinks' = {
    name: 'privateDnsZoneLink-hub'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: hubVirtualNetworkId
      }
    }
  }
}



output apiManagementName string = apiManagement.name
