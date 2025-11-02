@description('Specifies the name of the container registry.')
param tags object 

@description('Specifies the location for all resources.')

param location string = resourceGroup().location

@description('Specifies the name of the system agent pool subnet.')
param prefix string

@description('Specifies the name of the user assigned identity.')
param userAssignedIdentityName string

@description('Specifies the name of the Log Analytics Workspace.')
param logAnalyticsWorkspaceName string

@description('Specifies the name of the ApplicationInsight')
param applicationInsightName string

@description('')
param adminUserObjectId string

@description('Specifies the SKU of the container registry.')
param  containerRegistrySku  string

@description('Specifies the name of the container registry.')
param containerRegistryName string 

@description('Specifies the name of the cluster   resource.')
param ClusterName string 

param sqlserverName string = 'sqlserver-${prefix}'

param sqlserverAdminLogin string = 'logcorner'
@secure()
param sqlserverAdminPassword string

param databaseName string = 'LogCorner.EduSync.Speech.Database'

param privateDnsZoneNames  array = [
  'privatelink.azurecr.io' , 'privatelink.vaultcore.azure.net','datasynchro.com','privatelink.database.windows.net','privatelink.${resourceGroup().location}.azmk8s.io'
]

@description('Specifies the namespace of the application.')
param workloadIdentityserviceAccounNamespace string 

@description('Specifies the service account of the application.')
param workloadIdentityServiceAccountName string 

@description('Specifies the name of the workload managed identity.')
param workloadManagedIdentityName string 



resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
  location: location
  tags: tags
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsWorkspaceName
  tags: tags
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightName
  location: location
  tags: tags
  kind: 'other'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}
 
module network 'modules/network.bicep' = {
  name: '${prefix}-network'
  params: {
    virtualNetworkName: '${prefix}-vnet'
    location: location
    virtualNetworkAddressSpace: ['10.200.0.0/16']
    aks_subnet_name: 'aks-subnet'
    appgw_subnet_name: 'appgw-subnet'
    aks_subnet_addressPrefix: '10.200.0.0/22'
    appgw_subnet_addressPrefix:'10.200.4.0/24'
    privatelink_subnet_name:'privatelink-subnet'
    privatelink_subnet_addressPrefix:'10.200.5.0/24'
    applicationGatewayForContainersSubnetName: 'appgwforcontainers-subnet'
    applicationGatewayForContainersSubnetAddressPrefix: '10.200.6.0/24'
  }
}

module peerFirstVnetSecondVnet 'modules/vnet_peering.bicep' = {
  name: 'peerFirstToSecond'
  scope: resourceGroup()
  params: {
    existingLocalVirtualNetworkName: network.outputs.virtualNetworkName
    existingRemoteVirtualNetworkName: 'datasynchro-hub-vnet'
    existingRemoteVirtualNetworkResourceGroupName: 'RG-DATASYNCHRO-HUB'
  }
}

module peerSecondVnetFirstVnet 'modules/vnet_peering.bicep' = {
  name: 'peerSecondToFirst'
  scope: resourceGroup('RG-DATASYNCHRO-HUB')
  params: {
    existingLocalVirtualNetworkName: 'datasynchro-hub-vnet'
    existingRemoteVirtualNetworkName: network.outputs.virtualNetworkName
    existingRemoteVirtualNetworkResourceGroupName: resourceGroup().name
  }
}

module PrivateDnsZone 'modules/private_dns_zone.bicep' = [for privateDnsZoneName in privateDnsZoneNames: {
  name: 'privateDnsZone-${privateDnsZoneName}'
  params: {
    privateDnsZoneName: privateDnsZoneName
    location: 'global'
    virtualNetworkId: [
      network.outputs.virtualNetworkId
      '/subscriptions/023b2039-5c23-44b8-844e-c002f8ed431d/resourceGroups/RG-DATASYNCHRO-HUB/providers/Microsoft.Network/virtualNetworks/datasynchro-hub-vnet'
    ]
  }
}]


module aksCluster 'modules/aks.bicep' = {
  name: 'aks-cluster'
  params: {
    ClusterName: ClusterName
    location: location
    prefix: prefix
    userAssignedIdentities: managedIdentity.id
    acrName: containerRegistryName
     vmSize: 'Standard_DS2_v2'
    privateDNSZoneName: 'privatelink.${resourceGroup().location}.azmk8s.io'
    SubnetId: network.outputs.aks_subnet_id
     tags: tags
     adminGroupObjectIDs: [adminUserObjectId]
      LoganalyticID: logAnalyticsWorkspace.id
       serviceAccountNamespace: workloadIdentityserviceAccounNamespace
    serviceAccountName: workloadIdentityServiceAccountName
    workloadManagedIdentityName: workloadManagedIdentityName
    workloadIdentityEnabled: true
    oidcIssuerProfileEnabled: true
  }
}
 
module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'containerRegistry'
  params: {
    name: containerRegistryName
    sku: containerRegistrySku
    adminUserEnabled : false
    location: location
     workspaceId: logAnalyticsWorkspace.id
    tags: tags
  }
}


module registryPrivateEndpoint 'modules/private_endpoint.bicep' = { 

  name: 'pe-${containerRegistryName}'
  params: {
    location: location
    privateEndpointName:  'pe-${containerRegistryName}'
    privateDnsZoneName : 'privatelink.azurecr.io'
    endpointDnsGroupName: 'pe-${containerRegistryName}/dnsgroup'
    privateLinkConnexionServiceName: 'cn-${containerRegistryName}'
    groupIds:[
      'registry'
    ]
    subnetId: network.outputs.privatelink_subnet_id
    privateLinkServiceId: containerRegistry.outputs.id
  }

  dependsOn: [
    PrivateDnsZone
  
  ]
}



module sqlserver 'modules/sql-server.bicep' = {
  name: 'sqlserver'
  params: {
    sqlServerName: sqlserverName
    adminLogin: sqlserverAdminLogin
    adminPassword: sqlserverAdminPassword
    databaseName: databaseName
    serverLocation: location

  }
  
}

module slqServerPrivateEndpoint 'modules/private_endpoint.bicep' = { 

  name: 'pe-${sqlserverName}'
  params: {
    location: location
    privateEndpointName:  'pe-${sqlserverName}'
    privateDnsZoneName : 'privatelink.database.windows.net'
    endpointDnsGroupName: 'pe-${sqlserverName}/dnsgroup'
    privateLinkConnexionServiceName: 'cn-${sqlserverName}'
    groupIds:[
      'sqlServer'
    ]
    subnetId: network.outputs.privatelink_subnet_id
    privateLinkServiceId: sqlserver.outputs.id
  }

  dependsOn: [
    PrivateDnsZone

  ]
}

 module servicebus 'modules/serviceBus.bicep' = {
  name: 'servicebus'
  params: {
    userAssignedIdentityName: managedIdentity.name
    location: location
    serviceBusNamespaceName: '${prefix}-sb-namespace'
    serviceBusQueueName: '${prefix}-sb-queue'
  }

}

module cosmosdb 'modules/cosmosdb.bicep' = {
  name: 'cosmosdb'
  params: {
    accountName: 'cosmos-${prefix}-001'
    location: location
    databaseName: 'LogCorner.EduSync.Speech.Database'
  }

}
 
module keyvault 'modules/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
    keyvault_name: 'kv-${prefix}-001'
      workloadManagedIdentityName:workloadManagedIdentityName
  }
dependsOn: [
    aksCluster
  ]
}


// Application Gateway for Containers

param userAssignedIdentities_azure_alb_identity_name string = 'azure_alb_identity'
@description('Specifies the name of the Application Gateway for Containers.')
param applicationGatewayForContainersName string = 'appgwforcon-${prefix}'


param nodeResourceGroupName string= 'MC_${resourceGroup().name}_${ClusterName}_${location}'

resource userAssignedIdentities_azure_alb_identity_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentities_azure_alb_identity_name
  location: location
}

/*  module gateway 'modules/applicationGatewayForContainers.bicep' = {
  name:'gateway'
  params: {
    
    trafficControllers_alb_name: applicationGatewayForContainersName
    location: location
    alb_subnet_id:network.outputs.applicationGatewayForContainersSubnet_id
     nodeResourceGroupName: nodeResourceGroupName
     userManagedIdentityprincipalId: userAssignedIdentities_azure_alb_identity_resource.properties.principalId
  
  }
  dependsOn: [
    aksCluster
  ]
} 

param controllerServiceAccountName string = 'alb-controller-sa'

param controllerNamespace string ='azure-alb-system'
 
resource userAssignedIdentities_azure_alb_identity_name_userAssignedIdentities_azure_alb_identity_name 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2025-01-31-preview' = {
  parent: userAssignedIdentities_azure_alb_identity_resource
  name: userAssignedIdentities_azure_alb_identity_name
  properties: {
    issuer: aksCluster.outputs.issuerUrl 
    subject: 'system:serviceaccount:${controllerNamespace}:${controllerServiceAccountName}' 
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
} 
 */
