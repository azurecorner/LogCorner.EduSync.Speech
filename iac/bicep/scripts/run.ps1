[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$sqlServerName,
    
    [Parameter(Mandatory = $true)]
    [string]$databaseName,
    
    [Parameter(Mandatory = $true)]
    [string]$sqlAdminUsername,
    
    [Parameter(Mandatory = $true)]
    [string]$sqlAdminPassword,
    
    [Parameter(Mandatory = $true)]
    [string]$sqlScriptBase64
)

# Decode the Base64-encoded SQL script
$sqlScript = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($sqlScriptBase64))

# Ensure the SqlServer module is installed
try {
    if (-not (Get-Module -ListAvailable -Name SqlServer)) {
        Write-Output "Installing SqlServer module..."
        Install-Module -Name SqlServer -Force -AllowClobber -Scope CurrentUser
    }
} catch {
    Write-Error "Error installing SqlServer module: $_"
    exit 1
}

# Determine the correct temporary storage path within Azure Deployment Scripts
$tempFolder = if ($Env:AZ_SCRIPTS_TEMP) { $Env:AZ_SCRIPTS_TEMP } else { "/mnt/azscripts/azscriptinput" }

# Ensure the temp folder exists
if (!(Test-Path $tempFolder)) {
    Write-Output "Creating temp folder: $tempFolder"
    New-Item -ItemType Directory -Path $tempFolder -Force
}

# Save the decoded SQL script to a temporary file
$tempSqlFile = Join-Path $tempFolder "tempScript.sql"
Set-Content -Path $tempSqlFile -Value $sqlScript

Write-Output "Executing SQL script against database [$databaseName] on server [$sqlServerName]..."

try 
{
    $constr = "Server=tcp:$($sqlServerName),1433;Database=$($databaseName);User ID=$($sqlAdminUsername);Password=$($sqlAdminPassword);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" # "Server=tcp:$sqlServerName,1433;Database=$databaseName;User ID=$sqlAdminUsername;Password=$sqlAdminPassword;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  
    Invoke-Sqlcmd -ConnectionString  $constr   -InputFile $tempSqlFile

    Write-Output "SQL script executed successfully."
} catch {
    Write-Error "An error occurred while executing the SQL script: $_"
    exit 1
}
