if ($IsLinux) {throw "This script relies on commands only present in powershell running on windows, but works in both 'windows powershell' and 'powershell'."}
. $PSScriptRoot\..\init.ps1
if (!(Get-Module Indented.Net.IP -ListAvailable)) { Install-Module -Name Indented.Net.IP -Scope CurrentUser -Force }
function Get-OrCreateNetboxSubnet ($prefix) {
    Try {
        if($SubnetObject=Get-NBPrefixByCIDR -CIDR $prefix) {}
        else {
            $SubnetObject=New-NBPrefix -prefix $prefix
        }
    }
    catch {
        throw "Could not create subnet object"
    }
}

function Invoke-PingSweep {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$Subnet,
        [Parameter(Mandatory = $false)][switch]$ResolveAllAddresses,
        [Parameter()][switch]$CreateSubnet
    )
    $Mask=$Subnet.Split('/')[1]
    if ($CreateSubnet) { Get-OrCreateNetboxSubnet $Subnet }
    $Addresses = Get-NetworkRange $Subnet
    $Addresses | ForEach-Object {
        Write-Verbose $_
        $Alive = Test-Connection -TargetName $_.IPAddressToString -Quiet -Count 1 -TimeoutSeconds 1
        If ($Alive) { 
            try {$DNSResult=(Resolve-DnsName $_ -ErrorAction Stop -QuickTimeout -DnsOnly).Namehost} catch {$DNSResult=$false} 
            if($IPObj=Get-NBIPAddressByName "$($_.IPAddressToString)/$($Mask)") {
                Set-NBIPAddress -id $IPObj.id -key dns_name -value $DNSResult
            }
            else {
                New-NBIPAddress -address "$($_.IPAddressToString)/$($Mask)"
            }
        }
        else {
            if($ResolveAllAddresses) {try {$DNSResult=(Resolve-DnsName $_ -ErrorAction Stop -QuickTimeout -DnsOnly).Namehost} catch {$DNSResult=$false}}
            else {$DNSResult='skipped'}
        }
        $IPResult=@{
            Address  = $_.IPAddressToString
            Alive    = $Alive
            HostName = $DNSResult
        }
        if ($IPObj=Get-NBIPAddressByName "$($IPResult.Address)/$($Mask)") {
            #if ($IPResult.Alive -and $IPObj.status -ne 'active') {Set-NBIPAddress -id $IPObj.id -key status -value 'active'}
            elseif (!($IPResult.Alive) ) {
                <# Action when this condition is true #>
            }
            Set-NBIPAddress -id $IPObj.id -key dns_name -value $IPResult.HostName
        }
        else {

            $IPObj=New-NBIPAddress -address "$($IPResult.Address)/$($Mask)" -status 
        }
        $IPObj=Get-OrCreateIPObject "$($IPResult.Address)/$($Mask)"


    }

    #$Results | Select-Object Address,Alive,HostName
    #$Results | Export-Csv .\Sweep-Log.csv -NoTypeInformation
}
