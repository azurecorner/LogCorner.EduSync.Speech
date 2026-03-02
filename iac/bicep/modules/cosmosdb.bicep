@description('Cosmos DB account name')
param accountName string 

@description('Location for the Cosmos DB account.')
param location string = resourceGroup().location

@description('The name for the SQL API database')
param databaseName string 

@description('The name for the SQL API container')
param containerName string = 'Speech'

param managedIdentityName string

@description('Optional principal ID to grant Cosmos DB SQL Built-in Data Contributor. Leave empty to skip.')
param jumpboxPrincipalId string 

@description('Optional principal ID to grant Cosmos DB SQL Built-in Data Contributor. Leave empty to skip.')
param adminPrincipalId string 

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

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-11-15' = {
  parent: database
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
    }
    options: {}
  }
}


output account_id string = account.id
output account_name string = account.name



resource workloadManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName

}

var roleDefinitionId = resourceId(
  'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions',
  accountName,
  '00000000-0000-0000-0000-000000000002'
)

resource assignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = if (!empty(jumpboxPrincipalId)) {
  name: guid(roleDefinitionId, jumpboxPrincipalId, account.id)
  parent: account
  properties: {
    principalId: jumpboxPrincipalId
    roleDefinitionId: roleDefinitionId
     scope: account.id
  }
} 

resource assignmentMe 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = if (!empty(adminPrincipalId)) {
  name: guid(roleDefinitionId, adminPrincipalId, account.id)
  parent: account
  properties: {
    principalId: adminPrincipalId
    roleDefinitionId: roleDefinitionId
    scope: account.id
  }
} 

resource assignmentManagedIdentity 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  name: guid(roleDefinitionId, workloadManagedIdentity.id, account.id)
  parent: account
  properties: {
    principalId: workloadManagedIdentity.properties.principalId
    roleDefinitionId: roleDefinitionId
    scope: account.id
  }
}
