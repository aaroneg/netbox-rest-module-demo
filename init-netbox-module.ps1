try {
    $nbConfig=Import-Clixml $PSScriptRoot\nbconfig.xml
}
catch {
    $nbConfig=@{
        netboxAddress = Read-Host -Prompt "IP address or hostname of Netbox server"
    }
    $nbConfig | Export-Clixml $PSScriptRoot\nbconfig.xml
}


Import-Module 'netbox-rest-module'

Try {
    Import-Module Microsoft.PowerShell.SecretManagement -ErrorAction Stop
    Import-Module Microsoft.PowerShell.SecretStore -ErrorAction Stop
}
Catch {
    Install-Module -Name Microsoft.PowerShell.SecretManagement -Repository PSGallery -Scope CurrentUser
    Install-Module -Name Microsoft.PowerShell.SecretStore -Repository PSGallery -Scope CurrentUser
    Register-SecretVault -Name SecretStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault -AllowClobber
}

try {$nbCred=Get-Secret -Name $nbConfig.netboxAddress -ErrorAction Stop}
catch {
    $nbCred=Get-Credential -Message "Credentials for $($netboxAddress)"
    Set-Secret -Name $nbConfig.netboxAddress -Secret $nbCred
}

$nbConnection = New-NbConnection -DeviceAddress $nbConfig.netboxAddress -ApiKey $nbCred.GetNetworkCredential().Password -Passthru
Write-Output "Netbox connection initiated:"
$nbConnection|Select-Object -Property Address,ApiBaseURL
