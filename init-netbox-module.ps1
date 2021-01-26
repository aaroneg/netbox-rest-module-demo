# Read or create a netbox config object
try {
    $nbConfig=Import-Clixml $PSScriptRoot\nbconfig.xml
}
catch {
    $nbConfig=@{
        netboxAddress = Read-Host -Prompt "IP address or hostname of Netbox server"
    }
    $nbConfig | Export-Clixml $PSScriptRoot\nbconfig.xml
}

# Module should already be in place if someone is running this demo but.. 
try {
    Import-Module 'netbox-rest-module'
}
catch {
    throw "netbox-rest-module is not installed or not installed in the correct location."
}

# Let's use the new secret management / secret store from Microsoft:
# https://devblogs.microsoft.com/powershell/secretmanagement-and-secretstore-release-candidates/
Try {
    Import-Module Microsoft.PowerShell.SecretManagement -ErrorAction Stop
    Import-Module Microsoft.PowerShell.SecretStore -ErrorAction Stop
}
Catch {
    Install-Module -Name Microsoft.PowerShell.SecretManagement -Repository PSGallery -Scope CurrentUser
    Install-Module -Name Microsoft.PowerShell.SecretStore -Repository PSGallery -Scope CurrentUser
    Register-SecretVault -Name SecretStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault -AllowClobber
}

# Get or create the API credential from the secret store
try {$nbCred=Get-Secret -Name $nbConfig.netboxAddress -ErrorAction Stop}
catch {
    $nbCred=Get-Credential -Message "Credentials for $($netboxAddress)"
    Set-Secret -Name $nbConfig.netboxAddress -Secret $nbCred
}

# Create the connection object we'll use later and show what it looks like without also printing the API key.
# This isn't a security measure, more security hygiene - secrets should not be unexpectedly printed to the screen
$nbConnection = New-NbConnection -DeviceAddress $nbConfig.netboxAddress -ApiKey $nbCred.GetNetworkCredential().Password -Passthru
Write-Output "Netbox connection initiated:"
$nbConnection|Select-Object -Property Address,ApiBaseURL
