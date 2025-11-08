metadata description = 'Create RBAC definition for control plane access to Azure Cosmos DB.'

@description('Name of the role definition.')
param roleDefinitionName string = 'Azure Cosmos DB Control Plane Owner'

@description('Description of the role definition.')
param roleDefinitionDescription string = 'Can perform all control plane actions for an Azure Cosmos DB account.'

resource definition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, roleDefinitionName)
  scope: resourceGroup()
  properties: {
    roleName: roleDefinitionName
    description: roleDefinitionDescription
    type: 'CustomRole'
    permissions: [
      {
        actions: [
          'Microsoft.DocumentDb/*'
        ]
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

output definitionId string = definition.id
