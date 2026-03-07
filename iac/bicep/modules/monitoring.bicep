// log analytics workspace parameters
@description('Specifies the name of the Log Analytics workspace.')
param logAnalyticsWorkspaceName string

@description('Specifies the service tier of the workspace: Free, Standalone, PerNode, Per-GB.')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param sku string = 'PerNode'

@description('Specifies the location.')
param location string = resourceGroup().location

// app insights parameters
param appInsightName string 
param type string 
param requestSource string 

// Action Group parameters

@description('Specifies the name of the Action Group resource.')
param name string

@description('Specifies the short name of the action group. This will be used in SMS messages..')
param groupShortName string = 'AksAlerts'

@description('Specifies whether this action group is enabled. If an action group is not enabled, then none of its receivers will receive communications.')
param enabled bool = true

@description('Specifies the email address of the receiver.')
param emailAddress string

@description('Specifies whether to use common alert schema..')
param useCommonAlertSchema bool = false

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: sku
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightName
  location: location
  kind: 'other'
  properties: {
    Application_Type: type
    Request_Source: requestSource
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: name
  location: 'Global'

  properties: {
    groupShortName: groupShortName
    enabled: enabled
    emailReceivers: !empty(emailAddress) ? [
      {
        name: 'EmailAndTextMessageOthers_-EmailAction-'
        emailAddress: emailAddress
        useCommonAlertSchema: useCommonAlertSchema
      }
    ] : []

    armRoleReceivers: [
      {
        name: 'EmailOwner'
        roleId: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
        useCommonAlertSchema: false
      }
    ]
  }
}

//Outputs
output actionGroupId string = actionGroup.id
output actionGroupName string = actionGroup.name
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
output logAnalyticsWorkspaceCustomerId string = logAnalyticsWorkspace.properties.customerId
