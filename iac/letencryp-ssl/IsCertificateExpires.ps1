Function IsCertificateExpires {
    [CmdletBinding()]
    Param
    (
      [parameter(Mandatory=$true)]
      [string]$certifcateEnvironment ,
      [string]$certificateName 
    )
    
    .{

      $environment = Get-ChildItem $curDir -Filter $certifcateEnvironment -Recurse | Where-Object {($_.psiscontainer)}
      $certificatePath = Get-ChildItem $environment -Filter $certificateName -Recurse | Where-Object {($_.psiscontainer)}

      $fileName = "$($certificatePath)/order.json"
      If (Test-Path $fileName )
      {
          $PowerShellObject = Get-Content -Path $fileName  | ConvertFrom-Json

          $certExpires = $PowerShellObject.CertExpires

          $Today = (Get-Date)

          $renewableDate =  $certExpires.AddDays(-7)

          $shouldRenewCertificate = $Today -gt $renewableDate
          Write-Output $shouldRenewCertificate
      }else{
        Write-Host "file $($fileName) does not exist"
        $shouldRenewCertificate = $false
     }
   
    }| Out-Null
    Return $shouldRenewCertificate
}
