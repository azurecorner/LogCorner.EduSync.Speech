param sqlServerName string 
@description('Location for the SQL Server.')
param adminLogin string 
@description('SQL Server admin login.')
@secure()
param adminPassword string
param databaseName string 
@description('Name of the SQL Database.')
param serverLocation string = resourceGroup().location

param clientIpAddress string 

resource sqlServer 'Microsoft.Sql/servers@2023-08-01' = {
  name: sqlServerName
  location: serverLocation
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
     publicNetworkAccess: 'Enabled' //  for development purposes, change to 'SecuredByPerimeter' for production
  }
}

 resource allowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2023-08-01' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
} 

resource allowClientIPAddress 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: sqlServer
  name: 'allowClientIPAddress'
  properties: {
    startIpAddress: clientIpAddress
    endIpAddress: clientIpAddress
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01' = {
  name: databaseName
  parent: sqlServer
  location: serverLocation
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
 }

output id string = sqlServer.id


