@description('Cosmos DB account name')
param accountName string 

@description('Location for the Cosmos DB account.')
param location string = resourceGroup().location

@description('The name for the SQL API database')
param databaseName string 

param workloadManagedIdentityName string

resource account 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: toLower(accountName)
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableFreeTier: true
    databaseAccountOfferType: 'Standard'
     publicNetworkAccess: 'Disabled'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
      }
    ]
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-11-15' = {
  parent: account
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      throughput: 1000
    }
  }
}


output account_id string = account.id
output account_name string = account.name



////////////////////////////////

// module sqlRoles 'sqlRoleAssignment.bicep' = {
//   name: 'sqlroles'
//   params: {
//     cosmosDbAccountName: account.name
//     functionAppPrincipalId: '7abf4c5b-9638-4ec4-b830-ede0a8031b25'
//   }
 
// }
 

/*  resource createCosmosRoleAssignment 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'createCosmosRoleAssignment'
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.61.0'
    timeout: 'PT10M'
    scriptContent: '''
      az cosmosdb sql role assignment create \
        --account-name cosmos-datasynchro-002 \
        --resource-group RG-EVENT-DRIVEN-ARCHITECTURE \
        --scope "/" \
        --principal-id 7abf4c5b-9638-4ec4-b830-ede0a8031b25 \
        --role-definition-id 00000000-0000-0000-0000-000000000002
    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
 */
//var roleDefinitionId='/subscriptions/023b2039-5c23-44b8-844e-c002f8ed431d/resourceGroups/RG-EVENT-DRIVEN-ARCHITECTURE/providers/Microsoft.DocumentDB/databaseAccounts/cosmos-datasynchro-002/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002'

resource workloadManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: workloadManagedIdentityName

}

var roleDefinitionId = resourceId(
  'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions',
  accountName,
  '00000000-0000-0000-0000-000000000002'
)

 resource assignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  name: guid(roleDefinitionId, '1874d709-8343-4c7a-926d-d4dbb1f66ffe', account.id)
  parent: account
  properties: {
    principalId: '1874d709-8343-4c7a-926d-d4dbb1f66ffe' // azure jumpbox system assigned principal Id
    roleDefinitionId: roleDefinitionId
    scope: account.id
  }
}

resource assignmentWorkloadManagedIdentity 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  name: guid(roleDefinitionId, workloadManagedIdentity.id, account.id)
  parent: account
  properties: {
    principalId: workloadManagedIdentity.properties.principalId
    roleDefinitionId: roleDefinitionId
    scope: account.id
  }
}
