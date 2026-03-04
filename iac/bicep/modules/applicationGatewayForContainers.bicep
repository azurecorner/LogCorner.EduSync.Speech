
param trafficControllers_alb_name string
param alb_subnet_id string

param userManagedIdentityprincipalId string

param nodeResourceGroupName string

@description('Specifies the location.')
param location string 

resource trafficControllers_alb_resource 'Microsoft.ServiceNetworking/trafficControllers@2025-03-01-preview' = {
  name: trafficControllers_alb_name
  location: location
  properties: {}
}

resource trafficControllers_alb_test_name_association 'Microsoft.ServiceNetworking/trafficControllers/associations@2025-03-01-preview' = {
  parent: trafficControllers_alb_resource
  name: 'datasynchro-association'
  location: location
  properties: {
    associationType: 'subnets'
    subnet: {
      id: alb_subnet_id
    }
  }
}

resource trafficControllers_alb_test_name_frontend 'Microsoft.ServiceNetworking/trafficControllers/frontends@2025-03-01-preview' = {
  parent: trafficControllers_alb_resource
  name: 'datasynchro-frontend'
  location: location
  properties: {}
}


module AppGwForContainersConfigurationManagerRole_roleAssignment 'roleAssignment.bicep' = {
  name: 'applyReaderRoleToAksRG'
  scope: resourceGroup()
  params: {
    identityPrincipalId: userManagedIdentityprincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'fbc52c3f-28ad-4303-a892-8a056630b8f1') //'fbc52c3f-28ad-4303-a892-8a056630b8f1'
    roleDescription: 'Apply Reader role to the AKS managed cluster resource group for the newly provisioned identity'
    principalType: 'ServicePrincipal'
  }
}

module readerRole 'roleAssignment.bicep' = {
  name: 'applyReaderRoleToAksManagedRG'
  scope: resourceGroup(nodeResourceGroupName)
  params: {
    identityPrincipalId: userManagedIdentityprincipalId
    roleDefinitionId:subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7') // 'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader
    roleDescription:  'Apply Reader role to the AKS managed cluster resource group for the newly provisioned identity'
    principalType: 'ServicePrincipal'
  }
 
}

module subnetAlbNetworkContributorAssignment 'roleAssignment.bicep' = {
  name: 'subnetAlbNetworkContributorAssignment'
  params: {
    identityPrincipalId: userManagedIdentityprincipalId
    roleDefinitionId:subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7') // Network Contributor
    roleDescription:  'Grant Network Contributor role on subnet-alb to the ALB managed identity'
    principalType: 'ServicePrincipal'
  }
 }

 