using './main.bicep'
// VNET
param prefix  = 'datasynchro'
param userAssignedIdentityName = 'managed-identity'
param logAnalyticsWorkspaceName  = 'law-datasynchro'

param  containerRegistrySku  = 'Premium'

param containerRegistryName  ='datasynchroacr'

param adminUserObjectId ='7abf4c5b-9638-4ec4-b830-ede0a8031b25'

param ClusterName ='datasynchro-aks' 

param tags  = {

  DeployedBy: 'Bicep'
}

param applicationInsightName = 'datasyncappi'

param sqlserverAdminPassword =  'MySecureP@ssword'
param workloadManagedIdentityName =  'workload-managed-identity-${prefix}'

@description('Specifies the namespace of the application.')
param workloadIdentityserviceAccounNamespace  = 'azure-resources'

@description('Specifies the service account of the application.')
param workloadIdentityServiceAccountName  = 'workload-identity-sa'
