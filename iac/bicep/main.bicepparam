using './main.bicep'
// VNET
param prefix  = 'datasynchro'
param userAssignedIdentityName = 'managed-identity'
param logAnalyticsWorkspaceName  = 'law-datasynchro'

param  containerRegistrySku  = 'Premium'

param containerRegistryName  ='datasynchroacr'

param adminUserObjectId ='7abf4c5b-9638-4ec4-b830-ede0a8031b25'

param ClusterName ='datasynchro-aks-002' 

param tags  = {

  DeployedBy: 'Bicep'
}

param applicationInsightName = 'datasyncappi'

param sqlserverAdminPassword =  'MySecureP@ssword'
