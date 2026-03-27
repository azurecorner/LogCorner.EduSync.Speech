@description('Specifies the tags applied to all supported resources.')
param tags object 

@description('Specifies the location for all resources.')

param location string = resourceGroup().location

@description('Specifies the prefix used when composing resource names.')
param prefix string

@description('Specifies the name of the user assigned identity.')
param userAssignedIdentityName string

@description('Specifies the name of the Log Analytics Workspace.')
param logAnalyticsWorkspaceName string

@description('Specifies the name of the ApplicationInsight')
param applicationInsightName string

@description('Specifies the Microsoft Entra object ID for the admin user or group.')
param adminUserObjectId string

@description('Specifies the SKU of the container registry.')
param  containerRegistrySku  string

@description('Specifies the name of the container registry.')
param containerRegistryName string 

@description('Specifies the name of the AKS cluster resource.')
param ClusterName string 

@description('Specifies the name of the Azure SQL Server resource.')
param sqlserverName string

@description('Specifies the administrator login name for the Azure SQL Server.')
param sqlserverAdminLogin string
@secure()
@description('Specifies the administrator password for the Azure SQL Server.')
param sqlserverAdminPassword string

@description('Specifies the name of the primary application database.')
param databaseName string

@description('Specifies the list of private DNS zone names to create and link to the virtual networks.')
param privateDnsZoneNames  array = [
  'privatelink.azurecr.io' , 'privatelink.vaultcore.azure.net','privatelink.database.windows.net','privatelink.${resourceGroup().location}.azmk8s.io','privatelink.documents.azure.com','privatelink.servicebus.windows.net','privatelink.file.core.windows.net','privatelink.cognitiveservices.azure.com'
]

@description('Specifies the name of the Azure Key Vault resource.')
param keyvault_name string 

@description('Specifies the namespace of the application.')
param workloadIdentityserviceAccounNamespace string 

@description('Specifies the service account of the application.')
param workloadIdentityServiceAccountName string 

@description('Specifies the name of the workload managed identity.')
param workloadManagedIdentityName string 

@description('Specifies the name of the hub virtual network used for peering.')
param hubVirtualNetworkName string

@description('Specifies the Kubernetes service account name used by the ALB controller.')
param controllerServiceAccountName string

@description('Specifies the Kubernetes namespace used by the ALB controller.')
param controllerNamespace string

// Network parameters
@description('Specifies the address space assigned to the spoke virtual network.')
param virtualNetworkAddressSpace array 
@description('Specifies the name of the AKS subnet.')
param aks_subnet_name string 
@description('Specifies the address prefix of the AKS subnet.')
param aks_subnet_addressPrefix string 
@description('Specifies the name of the application gateway subnet.')
param appgw_subnet_name string 
@description('Specifies the address prefix of the application gateway subnet.')
param appgw_subnet_addressPrefix string 
@description('Specifies the name of the private endpoint subnet.')
param privatelink_subnet_name string 
@description('Specifies the address prefix of the private endpoint subnet.')
param privatelink_subnet_addressPrefix string 
@description('Specifies the name of the Application Gateway for Containers subnet.')
param applicationGatewayForContainersSubnetName string 
@description('Specifies the address prefix of the Application Gateway for Containers subnet.')
param applicationGatewayForContainersSubnetAddressPrefix string 
@description('Specifies the name of the container instance subnet.')
param containerInstanceSubnetName string 
@description('Specifies the address prefix of the container instance subnet.')
param containerInstanceSubnetAddressPrefix string 
@description('Specifies the name of the API Management subnet.')
param appim_subnet_name string 
@description('Specifies the address prefix of the API Management subnet.')
param appim_subnet_addressPrefix string 

@description('Specifies the PowerShell deployment script content used to initialize database objects.')
param runScript string = loadTextContent('./scripts/run.ps1')
var createTablesScriptRaw = loadTextContent('./scripts/createTables.sql')
var createTablesScriptBase64 = base64(createTablesScriptRaw)
@description('Specifies the name of the storage account used by the deployment script.')
param storageAccountName string

@description('Specifies the name of the Azure Service Bus namespace.')
param serviceBusNamespaceName string
@description('Specifies the name of the Azure Service Bus queue.')
param serviceBusQueueName string


@description('Specifies the name of the Azure Cosmos DB account.')
param cosmosdbAccountName string
@description('Specifies the name of the Azure Cosmos DB database.')
param cosmosdbDatabaseName string
@description('Optional principal ID for Cosmos SQL Built-in Data Contributor (jumpbox/system identity). Leave empty to skip.')
param cosmosJumpboxPrincipalId string 

// Application Gateway for Containers
@description('Specifies the name of the user-assigned managed identity used by the ALB controller.')
param userAssignedIdentities_azure_alb_identity_name string
@description('Specifies the name of the Application Gateway for Containers.')
param applicationGatewayForContainersName string

  
// Azure OpenAI Service
@description('Specifies whether creating the Azure OpenAi resource or not.')
param openAiEnabled bool

@description('Specifies the name of the Azure OpenAI resource.')
param openAiName string


@description('Specifies the name of the AKS managed resource group that hosts cluster-managed resources.')
param nodeResourceGroupName string= 'MC_${resourceGroup().name}_${ClusterName}_${location}'


// Observability parameters


// *** Optional: Deploy Managed Prometheus and Grafana if monitoring is required. ***
@description('Specifies whether create or not Azure Monitor managed service for Prometheus and Azure Managed Grafana resources.')
param prometheusAndGrafanaEnabled bool 

@description('Specifies the name of the managed Prometheus resource.')
param managedPrometheusName string

@description('Specifies the name of the managed Grafana resource.')
param managedGrafana string

@description('Specifies the SKU of the managed Grafana resource.')
param    skuName string 

@description('Specifies the API key for the managed Grafana resource.')
param    apiKey string 


@description('Specifies whether to create an action group for alerting.')
param actionGroupEnabled bool

@description('Specifies the name of the action group.') 
param actionGroupShortName string

@description('Specifies the email address to use for the action group.')
@secure()
param actionGroupEmailvaAddress string

@description('Specifies whether to use the common alert schema for the action group.')
param actionGroupUseCommonAlertSchema  bool

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

module network 'modules/network.bicep' = {
  name: '${prefix}-network'
  params: {
    virtualNetworkName: '${prefix}-vnet'
    location: location
    virtualNetworkAddressSpace: virtualNetworkAddressSpace
    aks_subnet_name: aks_subnet_name
    appgw_subnet_name: appgw_subnet_name
    aks_subnet_addressPrefix: aks_subnet_addressPrefix
    appgw_subnet_addressPrefix: appgw_subnet_addressPrefix
    privatelink_subnet_name: privatelink_subnet_name
    privatelink_subnet_addressPrefix: privatelink_subnet_addressPrefix
    applicationGatewayForContainersSubnetName: applicationGatewayForContainersSubnetName
    applicationGatewayForContainersSubnetAddressPrefix: applicationGatewayForContainersSubnetAddressPrefix
    containerInstanceSubnetName: containerInstanceSubnetName
    containerInstanceSubnetAddressPrefix: containerInstanceSubnetAddressPrefix
    appim_subnet_name: appim_subnet_name
    appim_subnet_addressPrefix: appim_subnet_addressPrefix
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
    keyVaultName: keyvault_name
    SubnetId: network.outputs.aks_subnet_id
    tags: tags
    adminGroupObjectIDs: [adminUserObjectId]
    serviceAccountNamespace: workloadIdentityserviceAccounNamespace
    serviceAccountName: workloadIdentityServiceAccountName
    workloadManagedIdentityName: workloadManagedIdentityName
    workloadIdentityEnabled: true
    oidcIssuerProfileEnabled: true
  }
  dependsOn: [ 
    keyvault
  ]
}    
 
module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'containerRegistry'
  params: {
    name: containerRegistryName
    sku: containerRegistrySku
    adminUserEnabled : false
    location: location
     workspaceId: monitoring.outputs.logAnalyticsWorkspaceId
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
    clientIpAddress: '86.245.251.176'
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

module deploymentScript 'modules/deployment-script.bicep' =  {
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
  
// *** Service Bus Namespace and Queue ***

 module servicebus 'modules/serviceBus.bicep' = {
  name: serviceBusNamespaceName
  params: {
    userAssignedIdentityName: workloadManagedIdentityName
    location: location
    serviceBusNamespaceName:serviceBusNamespaceName
    serviceBusQueueName: serviceBusQueueName
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
 /*  dependsOn: [
    aksCluster 
  ] */
}

module gateway 'modules/applicationGatewayForContainers.bicep' = {
  name:'gateway'
  params: {
    trafficControllers_alb_name: applicationGatewayForContainersName
    location: location
    alb_subnet_id:network.outputs.applicationGatewayForContainersSubnet_id
    nodeResourceGroupName: nodeResourceGroupName
    userManagedIdentityprincipalId: userAssignedIdentities_azure_alb_identity_resource.properties.principalId
    appgwc_waf_policy_name: 'appgwc-waf-policy'
    appgwc_security_policy_name: 'appgwc-security-policy'
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
  
// OBSERVABILITY MODULES

module monitoring 'modules/monitoring.bicep' = {
  name: '${prefix}-monitoring'
  params: {
 logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
 appInsightName: applicationInsightName
 sku: 'PerGB2018'
   type: 'web'
    requestSource: 'CustomDeployment'
     name: '${prefix}-actionGroup'
    enabled: actionGroupEnabled
    groupShortName: actionGroupShortName
    emailAddress: actionGroupEmailvaAddress
    useCommonAlertSchema: actionGroupUseCommonAlertSchema
  }
}

module prometheus 'modules/managedPrometheus.bicep' = if (prometheusAndGrafanaEnabled){
  name: '${prefix}-managedPrometheus'
  params: {
    name: managedPrometheusName
    publicNetworkAccess: 'Enabled'
    location: location
    tags: tags
    clusterName: ClusterName
    actionGroupId: actionGroupEnabled ? monitoring.outputs.actionGroupId : ''
  }
}

module grafana 'modules/managedGrafana.bicep' =  if (prometheusAndGrafanaEnabled){
  name: '${prefix}-managedGrafana'
  params: {
    name: managedGrafana
    prometheusName: managedPrometheusName
    location: location
    tags: tags
    skuName: skuName
    apiKey: apiKey
    userId: adminUserObjectId
  }

  dependsOn: [
    prometheus
  ]
}     

 module openAi 'modules/openAi.bicep' = if (openAiEnabled) {
  name: 'openAi'
  params: {
    foundry_name: openAiName
    location: location
    foundry_sku: 'S0'
    project_name: '${openAiName}-project'
    PrivateDnsZone:'privatelink.cognitiveservices.azure.com'
    privatelink_subnet_id: network.outputs.privatelink_subnet_id
    workloadManagedIdentityName: workloadManagedIdentity.name
    workspaceId: monitoring.outputs.logAnalyticsWorkspaceId
  }
}
 
