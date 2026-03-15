param( 
    [string]$vaultName ,
    [string]$certificateName ,
    [string]$domain ,
    [SecureString] $pfxPassword 
 )
 # Convert plain text to SecureString if necessary
if ($pfxPassword -isnot [System.Security.SecureString]) {
    $pfxPassword = ConvertTo-SecureString $pfxPassword -AsPlainText -Force
}
# Create the root signing cert
# Get the current working directory
$currentPath = Get-Location

Write-Host "path = $currentPath"
$currentPath = "$currentPath\certificate"

if (-not (Test-Path -Path $currentPath)) {
    New-Item -Path $currentPath -ItemType Directory | Out-Null
}

Write-Host "Create the root signing cert"
$root = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
    -Subject "CN=$domain-signing-root" -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 4096 `
    -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign `
    -KeyUsage CertSign -NotAfter (get-date).AddYears(5)
# Create the wildcard SSL cert.

Write-Host "Create the wildcard SSL cert"
$ssl = New-SelfSignedCertificate -Type Custom -DnsName "*.$domain","$domain" `
    -KeySpec Signature `
    -Subject "CN=*.$domain" -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -Signer $root

    # Export CER of the root and SSL certs
Write-Host "Export CER of the root and SSL certs"
Export-Certificate -Type CERT -Cert $root -FilePath $currentPath\datasync-signing-root.cer
Export-Certificate -Type CERT -Cert $ssl -FilePath $currentPath\datasync-ssl.cer

# Export PFX of the root and SSL certs
Write-Host "Export PFX of the root and SSL certs"

Export-PfxCertificate -Cert $root -FilePath $currentPath\datasync-signing-root.pfx `
    -Password $pfxPassword
Export-PfxCertificate -Cert $ssl -FilePath $currentPath\datasync-ssl.pfx `
    -ChainOption BuildChain -Password $pfxPassword 


$pfxFilePath = "$currentPath\datasync-ssl.pfx" # Path to your PFX file

write-Host "Upload the PFX certificate to Azure Key Vault"
# Upload the PFX certificate to Azure Key Vault
Import-AzKeyVaultCertificate -VaultName $vaultName `
    -Name $certificateName `
    -FilePath $pfxFilePath `
    -Password $pfxPassword

# Upload the PFX certificate root to Azure Key Vault
$certificateName = "$certificateName-root"  # Replace with desired certificate name in Key Vault
$pfxFilePath = "$currentPath\datasync-signing-root.pfx" # Path to your PFX file

write-Host "Upload the PFX certificate root to Azure Key Vault"
# Upload the PFX certificate to Azure Key Vault
Import-AzKeyVaultCertificate -VaultName $vaultName `
    -Name $certificateName `
    -FilePath $pfxFilePath `
    -Password $pfxPassword
