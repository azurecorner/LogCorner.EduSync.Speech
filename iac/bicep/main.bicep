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
  'privatelink.azurecr.io' , 'privatelink.vaultcore.azure.net','datasynchro.com','privatelink.database.windows.net','privatelink.${resourceGroup().location}.azmk8s.io','privatelink.documents.azure.com','privatelink.servicebus.windows.net','privatelink.file.core.windows.net'
]

param keyvault_name string 

@description('Specifies the namespace of the application.')
param workloadIdentityserviceAccounNamespace string 

@description('Specifies the service account of the application.')
param workloadIdentityServiceAccountName string 

@description('Specifies the name of the workload managed identity.')
param workloadManagedIdentityName string 

param hubVirtualNetworkName string

param controllerServiceAccountName string = 'alb-controller-sa'

param controllerNamespace string ='azure-alb-system'

@description('Name of the private link subnet where the SQL Server private endpoint will be created.')
param runScript string = loadTextContent('./scripts/run.ps1')
var createTablesScriptRaw = loadTextContent('./scripts/createTables.sql')
var createTablesScriptBase64 = base64(createTablesScriptRaw)
@description('Name of the virtual network where the container instance subnet is located.')
param storageAccountName string

param serviceBusNamespaceName string = 'sb-namespace-${prefix}'
param serviceBusQueueName string = 'sb-queue-${prefix}'
param serviceBusDataOwnerServicePrincipalId string

param cosmosdbAccountName string = 'cosmos-${prefix}-002'
param cosmosdbDatabaseName string = 'LogCorner.EduSync.Speech.Database'
@description('Optional principal ID for Cosmos SQL Built-in Data Contributor (jumpbox/system identity). Leave empty to skip.')
param cosmosJumpboxPrincipalId string 

// Application Gateway for Containers

param userAssignedIdentities_azure_alb_identity_name string = 'azure_alb_identity'
@description('Specifies the name of the Application Gateway for Containers.')
param applicationGatewayForContainersName string = 'appgwforcon-${prefix}'

param nodeResourceGroupName string= 'MC_${resourceGroup().name}_${ClusterName}_${location}'

resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: hubVirtualNetworkName
  scope: resourceGroup('RG-DATASYNCHRO-HUB')
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
  location: location
  tags: tags
}

//  This user-defined managed identity used by the workload to connect to the Azure services with a security token issued by Azue Active Directory
resource workloadManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: workloadManagedIdentityName
  location: location
  tags: tags
}

resource userAssignedIdentities_azure_alb_identity_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentities_azure_alb_identity_name
  location: location
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
    containerInstanceSubnetName: 'containerinstance-subnet'
    containerInstanceSubnetAddressPrefix: '10.200.7.0/24'
  }
}

module peerFirstVnetSecondVnet 'modules/vnet_peering.bicep' = {
  name: 'peerFirstToSecond'
  scope: resourceGroup()
  params: {
    existingLocalVirtualNetworkName: network.outputs.virtualNetworkName
    existingRemoteVirtualNetworkName: hubVirtualNetworkName
    existingRemoteVirtualNetworkResourceGroupName: 'RG-DATASYNCHRO-HUB'
  }
}

module peerSecondVnetFirstVnet 'modules/vnet_peering.bicep' = {
  name: 'peerSecondToFirst'
  scope: resourceGroup('RG-DATASYNCHRO-HUB')
  params: {
    existingLocalVirtualNetworkName: hubVirtualNetworkName
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
     hubVirtualNetwork.id
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
    keyVaultName: keyvault_name
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

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-04-01' = {
  name: storageAccountName
  kind: 'StorageV2'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

module storagePrivateEndpoint 'modules/private_endpoint.bicep' = { 
  name: 'pe-${storageAccountName}'
  params: {
    location: location
    privateEndpointName:  'pe-${storageAccountName}'
    privateDnsZoneName : 'privatelink.file.core.windows.net'
    endpointDnsGroupName: 'pe-${storageAccountName}/dnsgroup'
    privateLinkConnexionServiceName: 'cn-${storageAccountName}'
    groupIds:[
      'file'
    ]
    subnetId: network.outputs.privatelink_subnet_id
    privateLinkServiceId: storageAccount.id
  }
}

/* module deploymentScript 'modules/deployment-script.bicep' =  {
  name: 'deployment-script'
  params: {
    location: location
    sqlServerName: '${sqlserverName}.database.windows.net'
    databaseName: databaseName
    sqlAdminUsername: sqlserverAdminLogin
    sqlAdminPassword: sqlserverAdminPassword
    runScript: runScript
    createTablesScriptBase64: createTablesScriptBase64
    subnetId: network.outputs.containerInstanceSubnet_id
    storageAccountName : storageAccountName
    userAssignedIdentityName: userAssignedIdentityName
  }
  dependsOn:   [
    storagePrivateEndpoint
    slqServerPrivateEndpoint
  ]
} 
 */
// *** Service Bus Namespace and Queue ***

 module servicebus 'modules/serviceBus.bicep' = {
  name: serviceBusNamespaceName
  params: {
    userAssignedIdentityName: workloadManagedIdentityName
    location: location
    serviceBusNamespaceName:serviceBusNamespaceName
    serviceBusQueueName: serviceBusQueueName
    serviceBusDataOwnerServicePrincipalId: serviceBusDataOwnerServicePrincipalId
    serviceBusDataOwnerAdminUserId: adminUserObjectId
  }
}

module servicebusPrivateEndpoint 'modules/private_endpoint.bicep' = { 
  name: 'pe-${serviceBusNamespaceName}'
  params: {
    location: location
    privateEndpointName:  'pe-${serviceBusNamespaceName}'
    privateDnsZoneName : 'privatelink.servicebus.windows.net'
    endpointDnsGroupName: 'pe-${serviceBusNamespaceName}/dnsgroup'
    privateLinkConnexionServiceName: 'cn-${serviceBusNamespaceName}'
    groupIds:[
      'namespace'
    ]
    subnetId: network.outputs.privatelink_subnet_id
    privateLinkServiceId: servicebus.outputs.id
  }

  dependsOn: [
    PrivateDnsZone
  ]
}

module cosmosdb 'modules/cosmosdb.bicep' = {
  name: cosmosdbAccountName
  params: {
    accountName: cosmosdbAccountName
    location: location
    databaseName: cosmosdbDatabaseName
    managedIdentityName:workloadManagedIdentityName
    jumpboxPrincipalId: cosmosJumpboxPrincipalId
    adminPrincipalId: adminUserObjectId
  }
}

module cosmosdbPrivateEndpoint 'modules/private_endpoint.bicep' = { 
  name: 'pe-${cosmosdbAccountName}'
  params: {
    location: location
    privateEndpointName:  'pe-${cosmosdbAccountName}'
    privateDnsZoneName : 'privatelink.documents.azure.com'
    endpointDnsGroupName: 'pe-${cosmosdbAccountName}/dnsgroup'
    privateLinkConnexionServiceName: 'cn-${cosmosdbAccountName}'
    groupIds:[
      'Sql'
    ]
    subnetId: network.outputs.privatelink_subnet_id
    privateLinkServiceId: cosmosdb.outputs.account_id
  }

  dependsOn: [
    PrivateDnsZone
  ]
}

module keyvault 'modules/keyvault.bicep' = {
  name: keyvault_name
  params: {
    location: location
    keyvault_name: keyvault_name
    workloadManagedIdentityName:workloadManagedIdentityName
    privatelink_subnet_id: network.outputs.privatelink_subnet_id
  }
  dependsOn: [
    aksCluster
  ]
}

module gateway 'modules/applicationGatewayForContainers.bicep' = {
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
  
