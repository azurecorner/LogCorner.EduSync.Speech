@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('Name of the Queue')
param serviceBusQueueName string 

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Specifies the name of the user assigned identity.')
param userAssignedIdentityName string

@description('Principal ID of the admin user to grant Azure Service Bus Data Owner role.')
param serviceBusDataOwnerAdminUserId string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: userAssignedIdentityName
}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 1
  }
  properties: {
     publicNetworkAccess: 'Disabled'
      
  }
}

resource namespaces_sb_namespace_datasynchro_name_default 'Microsoft.ServiceBus/namespaces/networkrulesets@2024-01-01' = {
  parent: serviceBusNamespace
  name: 'default'

  properties: {
    publicNetworkAccess: 'Disabled'
    defaultAction: 'Allow'

    trustedServiceAccessEnabled: true
  }
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  parent: serviceBusNamespace
  name: serviceBusQueueName
  properties: {
    lockDuration: 'PT5M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: false
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

var AzureServiceBusDataOwner = '090c5cfd-751d-490a-894a-3ce6f1109419'

/*  ------------------------------------------ Role Assignment ------------------------------------------ */
resource AzureServiceBusDataOwnerReference 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: AzureServiceBusDataOwner
  scope: tenant()
}


resource roleAssignmentUserManagedIdentity 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(AzureServiceBusDataOwnerReference.id, managedIdentity.id, serviceBusNamespace.id)
  scope: serviceBusNamespace
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: AzureServiceBusDataOwnerReference.id
    principalType: 'servicePrincipal'
  }
}


resource roleAssignmentAdminUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(AzureServiceBusDataOwnerReference.id, serviceBusDataOwnerAdminUserId, serviceBusNamespace.id)
  scope: serviceBusNamespace
  properties: {
    principalId: serviceBusDataOwnerAdminUserId
    roleDefinitionId: AzureServiceBusDataOwnerReference.id
    principalType: 'user'
  }
}

module AzureServiceBusDataOwnerrRole 'roleAssignment.bicep' = {
  name: 'AzureServiceBusDataOwnerRole'
  params: {
    roleDefinitionId: AzureServiceBusDataOwnerReference.id
    identityPrincipalId: managedIdentity.properties.principalId 
    roleDescription: 'Allows for full access to Azure Service Bus resources'
    principalType:'ServicePrincipal'
  }
}

output id string = serviceBusNamespace.id
