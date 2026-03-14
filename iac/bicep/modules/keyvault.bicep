param keyvault_name string

param workloadManagedIdentityName string

param privatelink_subnet_id string

param location string 


resource keyvault 'Microsoft.KeyVault/vaults@2024-12-01-preview' = {
  name: keyvault_name
  location : location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: 'f12a747a-cddf-4426-96ff-ebe055e215a3'

    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    enablePurgeProtection: true

    publicNetworkAccess: 'Enabled'
  }
}

resource keyvault_secret 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview' = {
  parent: keyvault
  name: 'my-secret-ds'
  
  properties: {
    attributes: {
      enabled: true
    }
    value: 'mySecretValue'
  }
}

/*
// Azure application gateway for containers needs to access secrets in the key vault, so we will assign the Key Vault Secrets User role to the managed identity used by the application gateway for containers and Key Vault Secrets Officer role to a user who will manage the secrets in the key vault.
// Example of assigning Key Vault Secrets Officer role to a user and Key Vault Secrets User role to a managed identity
resource workloadManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: workloadManagedIdentityName
  
}*/

module KeyVaultSecretsOfficerRole 'roleAssignment.bicep' = {
  name: 'KeyVaultSecretsOfficer'
  params: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7') // Key Vault Secrets Officer
    identityPrincipalId: '7abf4c5b-9638-4ec4-b830-ede0a8031b25' // User Object ID
    roleDescription: 'Perform any action on the secrets of a key vault, except manage permissions'
    principalType:'User'
  }
}

module KeyVaultCertificatesOfficerRole 'roleAssignment.bicep' = {
  name: 'KeyVaultCertificatesOfficer'
  params: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a4417e6f-fecd-4de8-b567-7b0420556985') // Key Vault Certificates Officer
    identityPrincipalId: '7abf4c5b-9638-4ec4-b830-ede0a8031b25' // User Object ID
    roleDescription: 'Perform any action on the certificates of a key vault, except manage permissions'
    principalType:'User'
  }
}

