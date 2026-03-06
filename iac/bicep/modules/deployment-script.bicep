param location string
param sqlServerName string
param databaseName string
@secure()
param sqlAdminUsername string
@secure()
param sqlAdminPassword string
param runScript string
param createTablesScriptBase64 string
param storageAccountName string
param subnetId string
param userAssignedIdentityName string

var storageFileDataPrivilegedContributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '69566ab7-960f-475b-8e7c-b3118f30c6bd')

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: userAssignedIdentityName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-04-01' existing = {
  name: storageAccountName

}


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageFileDataPrivilegedContributorRoleDefinitionId,managedIdentity.id, storageAccount.id)
  scope: storageAccount
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: storageFileDataPrivilegedContributorRoleDefinitionId
    principalType: 'ServicePrincipal'
  }
}


#disable-next-line BCP081
resource runSqlDeployment 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'run-sql-deployment'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}' : {}
    }
  }
  properties: {
    azPowerShellVersion: '11.0'
    retentionInterval: 'PT1H'
    timeout: 'PT15M'
    forceUpdateTag: '1'
    scriptContent: runScript

    storageAccountSettings: {
      storageAccountName: storageAccountName
    }
    containerSettings: {
      containerGroupName: 'cn-run-sql-deployment'
       subnetIds: [
        {
          id: subnetId 
        }
      ]
    } 
    // Pass the Base64-encoded SQL script safely to avoid parsing errors
    arguments: '-sqlServerName "${sqlServerName}" -databaseName "${databaseName}" -sqlAdminUsername "${sqlAdminUsername}" -sqlAdminPassword "${sqlAdminPassword}" -sqlScriptBase64 "${createTablesScriptBase64}"'
  }
}

output scriptStatus string = runSqlDeployment.properties.provisioningState
