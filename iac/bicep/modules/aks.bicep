@description('Location for all resources.')
param location string = resourceGroup().location

@description('The name prefix for all resources.')
param prefix string

@description('The name of the user assigned identity to be used by the AKS cluster.')
param userAssignedIdentities string 


@description('Log analytics ID on Input.')
param LoganalyticID string

@description('ACR name on Input.')
param acrName string

@description('ObjectIDs of admin groups who will have access to the cluster.')
param adminGroupObjectIDs array
@description('The name of the AKS cluster.')
param ClusterName string 

@description('Specifies the resource tags.')
param tags object

param SubnetId string

param vmSize string 

param privateDNSZoneName string

@description('The role definition ID for the ACR pull role.')
var acrPullRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

var enablePrivateCluster = true

@description('The role definition ID for the Kubernetes Service RBAC Cluster Admin role.')
var kubernetesServiceRBACClusterAdminId = resourceId('Microsoft.Authorization/roleDefinitions', 'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b')

resource privatednsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: privateDNSZoneName
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2025-02-01' = {
  name: ClusterName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentities}': {}
    }
  }
  properties: {
    dnsPrefix: '${prefix}-aks-dns'
  
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'azure'
      networkPolicy: 'azure'
    }

    addonProfiles: {
        omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: LoganalyticID
        }
      }
    }
   
    agentPoolProfiles: [
      {
       name: 'agentpool'
        osDiskSizeGB: 128
        count: 1
        enableAutoScaling: true
        minCount: 1
        maxCount: 2
        vmSize: vmSize
        osType: 'Linux'
        osSKU: 'Ubuntu'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 110
        enableNodePublicIP: false
        vnetSubnetID: SubnetId
      }      
    ]
    autoScalerProfile: {
      expander: 'random'
    }
    oidcIssuerProfile: {
      enabled: true
    }

     /* apiServerAccessProfile: {
      enablePrivateCluster: enablePrivateCluster
      privateDNSZone:  privatednsZone.id
      
    }    */
      aadProfile: {
      adminGroupObjectIDs: adminGroupObjectIDs
      enableAzureRBAC: true
      managed: true
      tenantID: tenant().tenantId
    }

    
  } 
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' existing= {
  name: acrName
}

resource acrKubeletAcrPullRole_roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: containerRegistry
  name: guid(containerRegistry.id,aksCluster.id,acrPullRoleDefinitionId)
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    description: 'Allows AKS to pull container images from this ACR instance.'
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
} 

resource kubernetesServiceClusterAdminRole_roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: aksCluster
  name: guid(aksCluster.id,aksCluster.id,kubernetesServiceRBACClusterAdminId)
  properties: {
    roleDefinitionId: kubernetesServiceRBACClusterAdminId
    description: 'Azure Kubernetes Service RBAC Cluster Admin Role to manage all resources in the cluster.'
    principalId: adminGroupObjectIDs[0]
    principalType: 'User'
  }
} 

output id string = aksCluster.id
output name string = aksCluster.name
output aksOidcIssuerUrl string = aksCluster.properties.oidcIssuerProfile.issuerURL 
output kubeletidentityObjectId string =aksCluster.properties.identityProfile.kubeletidentity.objectId
