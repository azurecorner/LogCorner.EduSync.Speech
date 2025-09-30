@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('Name of the Queue')
param serviceBusQueueName string 

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Specifies the name of the user assigned identity.')
param userAssignedIdentityName string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: userAssignedIdentityName
}


resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}
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

resource roleAssignmentServicePrincipal 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(AzureServiceBusDataOwnerReference.id, '27216efd-6abc-4bbe-aef1-bbe545a41dc4', serviceBusNamespace.id)
  scope: serviceBusNamespace
  properties: {
    principalId: '27216efd-6abc-4bbe-aef1-bbe545a41dc4'
    roleDefinitionId: AzureServiceBusDataOwnerReference.id
    principalType: 'servicePrincipal'
  }
}

resource roleAssignmentAdminUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(AzureServiceBusDataOwnerReference.id,'7abf4c5b-9638-4ec4-b830-ede0a8031b25', serviceBusNamespace.id)
  scope: serviceBusNamespace
  properties: {
    principalId: '7abf4c5b-9638-4ec4-b830-ede0a8031b25'
    roleDefinitionId: AzureServiceBusDataOwnerReference.id
    principalType: 'user'
  }
}


