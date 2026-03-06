
param trafficControllers_alb_name string
param alb_subnet_id string

param userManagedIdentityprincipalId string

param nodeResourceGroupName string

@description('Specifies the location.')
param location string 

resource applicationGatewayForContainer 'Microsoft.ServiceNetworking/trafficControllers@2025-03-01-preview' = {
  name: trafficControllers_alb_name
  location: location
  properties: {}
}

resource trafficControllers_network_association 'Microsoft.ServiceNetworking/trafficControllers/associations@2025-03-01-preview' = {
  parent: applicationGatewayForContainer
  name: 'datasynchro-association'
  location: location
  properties: {
    associationType: 'subnets'
    subnet: {
      id: alb_subnet_id
    }
  }
}

resource trafficControllers_frontend 'Microsoft.ServiceNetworking/trafficControllers/frontends@2025-03-01-preview' = {
  parent: applicationGatewayForContainer
  name: 'datasynchro-frontend'
  location: location
  properties: {}
}

@description('Specifies the name of the Application Gateway for Containers WAF policy.')
param appgwc_waf_policy_name string 

@description('Specifies the name of the Application Gateway for Containers security policy.')
param appgwc_security_policy_name string 


resource waf_policy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2024-07-01' = {
  name: appgwc_waf_policy_name
  location: location
  properties: {
    customRules: [
      {
        name: 'RateLimite'
        priority: 3
        ruleType: 'RateLimitRule'
        rateLimitDuration: 'OneMin'
        action: 'Block'
        rateLimitThreshold: 100
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'IPMatch'
            negationConditon: false
            matchValues: [
              '52.250.216.29'
            ]
            transforms: []
          }
        ]
        groupByUserSession: [
          {
            groupByVariables: [
              {
                variableName: 'ClientAddr'
              }
            ]
          }
        ]
        state: 'Enabled'
      }
    ]
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      state: 'Enabled'
      mode: 'Prevention'
      requestBodyInspectLimitInKB: 128
      fileUploadEnforcement: true
      requestBodyEnforcement: true
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.1'
          ruleGroupOverrides: []
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '1.1'
          ruleGroupOverrides: []
        }
      ]
      exclusions: []
    }
  }
}

resource security_policy 'Microsoft.ServiceNetworking/trafficControllers/securityPolicies@2025-03-01-preview' = {
  parent: applicationGatewayForContainer
  location: location
  name: appgwc_security_policy_name 
  properties: {
    wafPolicy: {
      id: waf_policy.id
    }
}
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

 