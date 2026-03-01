using './main.bicep'
// VNET
param prefix  = 'datasynchro'

param tags  = {

  DeployedBy: 'Bicep'
}

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
