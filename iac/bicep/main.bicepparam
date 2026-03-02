using './main.bicep'
// VNET
param prefix  = 'datasynchro'

param tags  = {

  DeployedBy: 'Bicep'
}
param hubVirtualNetworkName = 'VNET-HUB'

param userAssignedIdentityName = 'managed-identity'
param logAnalyticsWorkspaceName  = 'law-datasynchro'

param  containerRegistrySku  = 'Premium'

param containerRegistryName  ='datasynchroacr'

param storageAccountName = 'datasyncstg'

param adminUserObjectId ='7abf4c5b-9638-4ec4-b830-ede0a8031b25'

param ClusterName ='datasynchro-aks' 

param applicationInsightName = 'datasyncappi'

param sqlserverAdminPassword =  'MySecureP@ssword'
param workloadManagedIdentityName =  'workload-managed-identity'

param workloadIdentityserviceAccounNamespace  = 'azure-resources'

param workloadIdentityServiceAccountName  = 'workload-identity-sa'

//param cosmosAdminPrincipalId = '7abf4c5b-9638-4ec4-b830-ede0a8031b25' // Object ID of the user or service principal to be granted admin access to Cosmos DB. Replace with actual value.

param cosmosJumpboxPrincipalId =  '367790c8-560f-4506-8f81-47bba7117b26' // Object ID of the user or service principal to be granted access to Cosmos DB from a jumpbox. Replace with actual value.

//param serviceBusDataOwnerAdminUserId = '7abf4c5b-9638-4ec4-b830-ede0a8031b25'
param serviceBusDataOwnerServicePrincipalId = '27216efd-6abc-4bbe-aef1-bbe545a41dc4' // BICEP_SP => Object ID of the user or service principal to be granted admin access to Service Bus. Replace with actual value.
