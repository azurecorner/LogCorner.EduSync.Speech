
Param
    (
      [parameter(Mandatory=$true)]
      [string]$AcmeDirectory,
      [parameter(Mandatory=$true)]
      [string]$AcmeContact,
      [parameter(Mandatory=$true)]
      [string]$storageAccountName,
      [parameter(Mandatory=$true)]
      [string]$storageContainerName,
      [parameter(Mandatory=$true)]
      [string]$resourceGroupName,
      [parameter(Mandatory=$true)]
      [string]$KeyVaultName
    )

Write-Host "AcmeDirectory : $AcmeDirectory"
Write-Host "AcmeContact : $AcmeContact"
Write-Host "storageAccountName : $storageAccountName"
Write-Host "storageContainerName : $storageContainerName"
Write-Host "resourceGroupName : $resourceGroupName"
Write-Host "KeyVaultName : $KeyVaultName"

$curDir = Get-Location
Write-Host "Current Working Directory: $curDir"

Import-Module "$($curDir)\getStorageSasToken.ps1"


Connect-AzAccount -Identity
$azureAccessToken = Get-AzAccessToken -ResourceUrl "https://management.core.windows.net/";

 # Order or renew a certificate via ACME
./RenewAcmeCertificate.ps1 -AcmeDirectory $AcmeDirectory `
                          -AcmeContact $AcmeContact `
                          -CertificateName $CertificateName `
                          -SubscriptionId $SubscriptionId `
                          -AzureAccessToken $azureAccessToken.Token  `
                          -resourceGroupName $resourceGroupName  `
                          -storageAccountName $storageAccountName  `
                          -storageContainerName $storageContainerName



 # Import the certificate into Azure Key Vault

 
./ImportAcmeCertificateToKeyVault.ps1 -CertificateName $CertificateName  `
                                       -KeyVaultName $KeyVaultName  `
                                       -resourceGroupName $resourceGroupName `
                                       -AcmeDirectory $AcmeDirectory   

