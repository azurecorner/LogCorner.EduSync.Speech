param foundry_name string

param location string

param foundry_sku string = 'S0'

param project_name string 

param privatelink_subnet_id string

param PrivateDnsZone string

param workloadManagedIdentityName string

param workspaceId string

// Variables
var diagnosticSettingsName = 'diagnosticSettings'
var openAiLogCategories = [
  'Audit'
  'RequestResponse'
  'Trace'
]
var openAiMetricCategories = [
  'AllMetrics'
]
var openAiLogs = [for category in openAiLogCategories: {
  category: category
  enabled: true
}]
var openAiMetrics = [for category in openAiMetricCategories: {
  category: category
  enabled: true
}]

//  This user-defined managed identity used by the workload to connect to the Azure services with a security token issued by Azue Active Directory
resource workloadManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: workloadManagedIdentityName

}

resource accounts_open_ai_foundry 'Microsoft.CognitiveServices/accounts@2025-10-01-preview' = {
  name: foundry_name
  location: location
  sku: {
    name: foundry_sku
  }
  kind: 'AIServices'

 identity: {
    type: 'SystemAssigned'
 }
  properties: {
    apiProperties: {}
    customSubDomainName: foundry_name
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    allowProjectManagement: true
    defaultProject: project_name
    associatedProjects: [
      project_name
    ]
    publicNetworkAccess: 'Disabled'
    storedCompletionsDisabled: false
  }
}

resource foundry_project 'Microsoft.CognitiveServices/accounts/projects@2025-10-01-preview' = {
  parent: accounts_open_ai_foundry
  name: project_name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Default project created with the resource'
    displayName: project_name
  }
}

resource foundry_model 'Microsoft.CognitiveServices/accounts/deployments@2025-10-01-preview' = {
  parent: accounts_open_ai_foundry
  name: 'gpt-4.1-mini'
  sku: {
    name: 'Standard'
    capacity: 250
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4.1-mini'
      version: '2025-04-14'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    currentCapacity: 250
    raiPolicyName: 'Microsoft.DefaultV2'
    deploymentState: 'Running'
  }
}

module cosmosdbPrivateEndpoint 'private_endpoint.bicep' = { 
  name: 'pe-${foundry_name}'
  params: {
    location: location
    privateEndpointName:  'pe-${foundry_name}'
    privateDnsZoneName : PrivateDnsZone
    endpointDnsGroupName: 'pe-${foundry_name}/dnsgroup'
    privateLinkConnexionServiceName: 'cn-${foundry_name}'
    groupIds:[
      'account'
    ]
    subnetId: privatelink_subnet_id
    privateLinkServiceId: accounts_open_ai_foundry.id
  }
  dependsOn: [
#disable-next-line no-unnecessary-dependson
    accounts_open_ai_foundry
  ]
}

module azureAiUserRoleAssignment 'roleAssignment.bicep' = {
  name: 'azureAiUserRoleAssignment'
  params: {
    identityPrincipalId: workloadManagedIdentity.properties.principalId
    roleDefinitionId:subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '53ca6127-db72-4b80-b1b0-d745d6d5456d') // Azure AI User
    roleDescription:  'Grants reader access to AI projects, reader access to AI accounts, and data actions for an AI project.'
    principalType: 'ServicePrincipal'
  }
 }

resource openAiDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: accounts_open_ai_foundry
  properties: {
    workspaceId: workspaceId
    logs: openAiLogs
    metrics: openAiMetrics
  }
}

// Outputs
output id string = accounts_open_ai_foundry.id
output name string = accounts_open_ai_foundry.name
