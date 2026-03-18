using './main.bicep'
// VNET
param prefix  = 'datasynchro'

param tags  = {

  DeployedBy: 'Bicep'
}
param hubVirtualNetworkName = 'VNET-HUB'

// Network - VNet address space
param virtualNetworkAddressSpace = ['10.200.0.0/16']

// Network - Subnets
param aks_subnet_name = 'aks-subnet'
param aks_subnet_addressPrefix = '10.200.0.0/22'
param appgw_subnet_name = 'appgw-subnet'
param appgw_subnet_addressPrefix = '10.200.4.0/24'
param privatelink_subnet_name = 'privatelink-subnet'
param privatelink_subnet_addressPrefix = '10.200.5.0/24'
param applicationGatewayForContainersSubnetName = 'appgwforcontainers-subnet'
param applicationGatewayForContainersSubnetAddressPrefix = '10.200.6.0/24'
param containerInstanceSubnetName = 'containerinstance-subnet'
param containerInstanceSubnetAddressPrefix = '10.200.7.0/24'
param appim_subnet_name = 'apim-subnet'
param appim_subnet_addressPrefix = '10.200.8.0/24'

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

param workloadIdentityserviceAccounNamespace  = 'azure-workloads'

param workloadIdentityServiceAccountName  = 'workload-identity-sa'

param cosmosJumpboxPrincipalId =  '367790c8-560f-4506-8f81-47bba7117b26' // Object ID of the user or service principal to be granted access to Cosmos DB from a jumpbox. Replace with actual value.

param keyvault_name =  'kv-datasynchro-004'

param actionGroupEmailvaAddress =  'leyegora@gmail.com'

param actionGroupEnabled =  true

param actionGroupShortName =  'dsyncagrp'

param actionGroupUseCommonAlertSchema = true

param  apiKey  ='Enabled'

param managedGrafana =  'datasynchro-grafana'

param managedPrometheusName =  'datasynchro-prometheus'

param prometheusAndGrafanaEnabled =  true

param  skuName  = 'Standard'

// SQL Server
param sqlserverName = 'sqlserver-datasynchro'
param sqlserverAdminLogin = 'logcorner'
param databaseName = 'LogCorner.EduSync.Speech.Database'

// AKS ALB Controller
param controllerServiceAccountName = 'alb-controller-sa'
param controllerNamespace = 'azure-alb-system'

// Service Bus
param serviceBusNamespaceName = 'sb-namespace-datasynchro'
param serviceBusQueueName = 'sb-queue-datasynchro'

// Cosmos DB
param cosmosdbAccountName = 'cosmos-datasynchro-002'
param cosmosdbDatabaseName = 'LogCorner.EduSync.Speech.Database'

// Application Gateway for Containers
param userAssignedIdentities_azure_alb_identity_name = 'azure_alb_identity'
param applicationGatewayForContainersName = 'appgwforcon-datasynchro'

// Azure OpenAI
param openAiEnabled = true
param openAiName = 'datasynchro-openai-004'
