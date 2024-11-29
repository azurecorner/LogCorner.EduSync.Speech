param (
    [string] $CertificateName,
    [string] $KeyVaultName,
    [string] $resourceGroupName,
    [string] $AcmeDirectory
)

try {

$vault = Get-AzKeyVault -VaultName $KeyVaultName -ResourceGroupName $resourceGroupName
$KeyVaultResourceId = $vault.ResourceId

Write-Host "KeyVaultResourceId : $($KeyVaultResourceId)"
# For wildcard certificates, Posh-ACME replaces * with ! in the directory name
$certificateName = $certificateName.Replace('*', '!')

# Set working directory
$workingDirectory = Join-Path -Path "." -ChildPath "pa"

# Set Posh-ACME working directory
$env:POSHACME_HOME = $workingDirectory
Import-Module -Name Posh-ACME -Force

# Resolve the details of the certificate

$currentAccountName = (Get-PAAccount).id

# Determine paths to resources

$orderDirectoryPath = Join-Path -Path $workingDirectory -ChildPath $AcmeDirectory | Join-Path -ChildPath $currentAccountName | Join-Path -ChildPath $certificateName
$orderDataPath = Join-Path -Path $orderDirectoryPath -ChildPath "order.json"
$pfxFilePath = Join-Path -Path $orderDirectoryPath -ChildPath "fullchain.pfx"

# If we have a order and certificate available
if ((Test-Path -Path $orderDirectoryPath) -and (Test-Path -Path $orderDataPath) -and (Test-Path -Path $pfxFilePath)) {

    $pfxPass = (Get-PAOrder $certificateName).PfxPass

    # Load PFX
    $certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $pfxFilePath, $pfxPass, 'EphemeralKeySet'

    # Get the current certificate from key vault (if any)
   
    $azureKeyVaultCertificateName = $certificateName.Replace(".", "-").Replace("!", "wildcard")
    $keyVaultResource = Get-AzResource -ResourceId $KeyVaultResourceId
    $azureKeyVaultCertificate = Get-AzKeyVaultCertificate -VaultName $keyVaultResource.Name -Name $azureKeyVaultCertificateName -ErrorAction SilentlyContinue

    # If we have a different certificate, import it
    If (-not $azureKeyVaultCertificate -or $azureKeyVaultCertificate.Thumbprint -ne $certificate.Thumbprint) {
        Import-AzKeyVaultCertificate -VaultName $keyVaultResource.Name -Name $azureKeyVaultCertificateName -FilePath $pfxFilePath -Password (ConvertTo-SecureString -String $pfxPass -AsPlainText -Force) | Out-Null

        Write-Host "imported  $azureKeyVaultCertificateName  "
    }
}
else {
  Write-Host "cannot find $orderDirectoryPath  "
}


}
catch {
      Write-Host "error when importing certificate to azure kayvault" -ForegroundColor Red
      Write-Host "Message : $($_.Exception.Message)" -ForegroundColor Red
      Write-Host "Stack trace : $($_.Exception.StackTrace)" -ForegroundColor Red
}