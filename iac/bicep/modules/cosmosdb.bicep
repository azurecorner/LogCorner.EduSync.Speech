@description('Cosmos DB account name')
param accountName string 

@description('Location for the Cosmos DB account.')
param location string = resourceGroup().location

@description('The name for the SQL API database')
param databaseName string 

resource account 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: toLower(accountName)
  location: location
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



