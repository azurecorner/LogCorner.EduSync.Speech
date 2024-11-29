Function GetstorageAccountSasToken {
    [CmdletBinding()]
    Param
    (
      [parameter(Mandatory=$true)]
      [string]$resourceGroupName,
      [parameter(Mandatory=$true)]
      [string]$storageAccountName,
      [parameter(Mandatory=$true)]
      [string]$storageContainerName
     
    )
    
    . {
      try {
        $storageAccountKey = Get-AzStorageAccountKey -Name $storageAccountName  -ResourceGroupName $resourceGroupName | Select-Object -First 1 -ExpandProperty Value
        $storageContext = New-AzStorageContext -StorageAccountName $storageAccountName  -StorageAccountKey $storageAccountKey
        $storageContainerSASToken = New-AzStorageContainerSASToken -Name $storageContainerName  -Permission rwdl -Context $storageContext -FullUri -ExpiryTime (Get-Date).AddYears(5)
 
      }
      catch {
            Write-Host "error when retrieving storage container sas token " -ForegroundColor Red
            Write-Host "Message : $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Stack trace : $($_.Exception.StackTrace)" -ForegroundColor Red
      }

    } | Out-Null
    Return $storageContainerSASToken
    
}