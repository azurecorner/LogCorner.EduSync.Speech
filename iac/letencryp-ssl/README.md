# certificates-script
To create a repo for ssl certificate scripts


1.  create a storage account and a container
1.  Create an azure ad application registration 
    use open id connect to the github repository

2. assign DNS Zone Contributor role to service principal
3. assign Storage Account Key Operators role for the storage account to the service principal
4. assign reader for the keyvault to the service principal
5. assign certificate get and import access policy for the keyvault to the service principal



Hi emmanuel, to deploy the ssl auto renew script, I need the a service principal withe the following roles :
- DNS Zone contributor  for the dns for which a certificate is requested 
- Keyvaul Reader role and Cerificate Get and Import access policies
- Reader role for the storage account that store the certificate order details 

I need to create a storage accout  and a container also



docker build . -t ssl-letencrypt-renew-image:1.0.0


docker run ssl-letencrypt-renew-image:1.0.0 -AcmeDirectory "LE_STAGE" -AcmeContact "leyegora@gmail.com" -storageAccountName "sslrenewstorage" -storageContainerName "sslcontainer" -resourceGroupName "CERTIFICATE-RENEWEL-DOCKER" -KeyVaultName "sslrenewvaut"

