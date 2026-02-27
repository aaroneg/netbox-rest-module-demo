$Tenants=Import-Csv -Path $PSScriptRoot\sample-data\tenants.csv
$Regions=Import-Csv -Path $PSScriptRoot\sample-data\regions.csv
$SiteGroups=Import-Csv -Path $PSScriptRoot\sample-data\site-groups.csv
$Sites=Import-Csv -Path $PSScriptRoot\sample-data\sites.csv
$Locations=Import-Csv -Path $PSScriptRoot\sample-data\locations.csv
$RackRoles=Import-csv -Path $PSScriptRoot\sample-data\rack-roles.csv
$Racks=Import-csv -Path $PSScriptRoot\sample-data\racks.csv
$Contacts=Import-Csv -Path $PSScriptRoot\sample-data\contacts.csv
$DeviceTypes=Import-Csv -Path $PSScriptRoot\sample-data\device-types.csv
$Devices=Import-Csv -Path $PSScriptRoot\sample-data\devices.csv


. $PSScriptRoot\init.ps1
function add-Tenants {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    $groups=$Tenants | Select-Object -Unique -ExpandProperty group
    foreach ($item in $groups) {
        New-NBTenantGroup -name $item | Out-Null
    }
    foreach ($Tenant in $Tenants) {
        New-NBTenant -name $Tenant.name -group (Get-NBTenantGroupByName $Tenant.group).id | Out-Null
    }
}

function add-regions {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    $Regions| ForEach-Object {
        New-NBRegion -name $_.name | Out-Null
    }
    # Double-running this loop to make sure all items exist before setting parent objects
    $Regions| ForEach-Object {
        if($_.parent) {
            Set-NBRegion -id (Get-NBRegionByName -name $_.name).id -key parent -value (Get-NBRegionByName -name $_.parent).id 
        }
    }
}

function add-siteGroups {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    $SiteGroups | ForEach-Object {
        New-NBSiteGroup -name $_.name | Out-Null
    }
    # Double-running this loop to make sure all items exist before setting parent objects
    $SiteGroups | ForEach-Object {
        if ($_.parent) {
            Set-NBSiteGroup -id (Get-NBSiteGroupByName $_.name).id -key parent -value (Get-NBSiteGroupByName -name $_.parent).id 
        }
    }
}

function add-sites {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    foreach ($site in $Sites) {
        $objParams = @{
            name           = $site.name
            status         = $site.status
            region         = (Get-NBRegionByName $site.region).id
            group          = (Get-NBSiteGroupByName $site.sitegroup).id
            facility       = $site.facility 
            time_zone      = $site.timezone 
            description    = $site.description 

        }
        $obj = New-NBSite @objParams | Out-Null
    }
}

function add-locations {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    foreach ($location in $Locations) {
        $objParams = @{
            name        = $location.name
            site        = (Get-NBSiteByName -name $location.site).id
            tenant      = (Get-NBTenantByName -name $location.tenant).id 
            description = $location.description 
        }
        $obj = New-NBLocation @objParams
    }
    # Double-running this loop to make sure all items exist before setting parent objects
    foreach ($location in $Locations){
        if ($location.parent) {
            Set-NBLocation -id (Get-NBLocationByName -name $location.name).id -key parent -value (Get-NBLocationByName -name $location.parent).id | Out-Null
        }
    }
}
function add-rackroles {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    $RackRoles | ForEach-Object {
        $obj = New-NBRackRole -name $_.Name -color $_.color
    }
}

function add-racks {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    $Racks | ForEach-Object {
        $objParams=@{
            name     = $_.name
            site     = (Get-NBSiteByName -name $_.site).id
            location = (Get-NBLocationByName -name $_.location).id
            role     = (Get-NBRackRoleByName -name $_.role).id
            tenant   = (Get-NBTenantByName -name $_.tenant).id
        }
        $obj = New-NBRack @objParams
    }
}

function add-contacts {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    $ContactGroups = $Contacts | Select-Object -ExpandProperty group -Unique
    foreach ($item in $ContactGroups) {
        New-NBContactGroup -name $item | Out-Null
    }
    $Contacts | ForEach-Object {
        $objParams= @{
            name    = $_.name
            title   = $_.title
            phone   = $_.phone
            email   = $_.email
            address = $_.address
            link    = $_.link
            group   = (Get-NBContactGroupByName -name  $_.group).id
        }
        $obj = New-NBContact @objParams
    }
}

function add-contactroles {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    New-NBContactRole -name "Technician" | Out-Null
}

function add-deviceroles {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    New-NBDeviceRole -name "server" -color "2568da" | Out-Null
    New-NBDeviceRole -name "switch" -color "65d60e" | Out-Null
    New-NBDeviceRole -name "power" -color "efe410"  | Out-Null
}

function add-manufacturers {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    New-NBManufacturer -name "Microsoft"     | Out-Null
    New-NBManufacturer -name "Apple"         | Out-Null
    New-NBManufacturer -name "Cisco"         | Out-Null
    New-NBManufacturer -name "Ruckus"        | Out-Null
    New-NBManufacturer -name "Juniper"       | Out-Null
    New-NBManufacturer -name "Dell"          | Out-Null
    New-NBManufacturer -name "CheapNetworks" | Out-Null
}

function add-platforms {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    New-NBDevicePlatform -name "Linux"   | Out-Null
    New-NBDevicePlatform -name "Windows" | Out-Null
}

function add-devicetypes {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    $DeviceTypes|ForEach-Object {
        if ($_.is_full_depth -eq 'true') {$_.is_full_depth= $true}
        else {$_.is_full_depth= $false}
        $objParams = @{
            manufacturer  = (Get-NBManufacturerByName $_.manufacturer).id
            model         = $_.model
            u_height      = $_.u_height
            is_full_depth = $_.is_full_depth
            comments      = $_.comments
        }
        $obj=New-NBDeviceType @objParams
        if ($_.subdevice_role) {
            Set-NBDeviceType -id $obj.id -key subdevice_role -value $_.subdevice_role
        }
    }
}

function add-devices {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    $Devices | ForEach-Object {
        $obj = New-NBDevice -name $_.name -device_type (Get-NBDeviceTypeByModel -model $_.model).id -role (Get-NBDeviceRoleByName $_.role).id -site (Get-NBSiteByName $_.site).id -tenant (Get-NBTenantByName -name $_.tenant).id
        if ($_.platform.length -gt 1) {Set-NBDevice -id $obj.id -key platform -value (Get-NBDevicePlatformByName -name $_.platform).id;(Get-NBDevicePlatformByName -name $_.platform).id}

    }
}

function add-vrfs {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    New-NBVRF -name "Tailwind Toys"
    New-NBVRF -name "Contoso Limited"
}

function add-vlangroups {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    New-NBVlanGroup -name "Tailwind Toys"
    New-NBVlanGroup -name "Contoso Limited"
}
function add-vlans {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    New-NBVLAN -name 'clients' -vid 2 -status active -tenant (Get-NBTenantByName "Tailwind Toys").id -site (Get-NBSiteByName "DTUL1").id
    New-NBVLAN -name 'servers' -vid 3 -status active -tenant (Get-NBTenantByName "Tailwind Toys").id -site (Get-NBSiteByName "DTUL1").id
    New-NBVLAN -name 'clients' -vid 4 -status active -tenant (Get-NBTenantByName "Contoso Limited").id -site (Get-NBSiteByName "DTUL1").id
    New-NBVLAN -name 'clients' -vid 5 -status active -tenant (Get-NBTenantByName "Contoso Limited").id -site (Get-NBSiteByName "DTUL1").id
}

$Prefixes=Import-csv $PSScriptRoot\sample-data\prefixes.csv
function add-prefixes {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    $Prefixes = $Prefixes |Where-object { 'false' -eq $_.is_aggregate }
    $Prefixes| % {
        $_
        $obj = New-NBPrefix -prefix $_.prefix
        Set-NBPrefix -id $obj.id -key vrf -value (Get-NBVRFByName $_.tenant).id
        Set-NBPrefix -id $obj.id -key tenant -value (Get-NBTenantByName $_.tenant).id
        Set-NBPrefix -id $obj.id -key vlan -value (Get-NBVlanByVID $_.vlan).id
    }
}

function add-ipranges {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    $obj = New-NBIPRange -start_address "192.168.0.100/24" -end_address "192.168.0.149/24" -status 'active'
    Set-NBIPRange -id $obj.id -key vrf -value (Get-NBVRFByName "Tailwind Toys").id
    Set-NBIPRange -id $obj.id -key tenant -value (Get-NBTenantByName "Tailwind Toys").id
    $obj = New-NBIPRange -start_address "192.168.0.100/24" -end_address "192.168.0.149/24" -status 'active'
    Set-NBIPRange -id $obj.id -key vrf -value (Get-NBVRFByName "Contoso Limited").id
    Set-NBIPRange -id $obj.id -key tenant -value (Get-NBTenantByName "Tailwind Toys").id
}
function add-vmclusterinformation {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    New-NBVMClusterType -name 'vmware' 
    New-NBVMClusterType -name 'xcp-ng' 
    New-NBVMClusterType -name 'proxmox' 
    New-NBVMClusterType -name 'hyper-v' 
    New-NBVMClusterType -name 'kvm' 
    New-NBVMClusterType -name 'xen' 
    New-NBVMClusterType -name 'lxc' 
    $Cluster=New-NBVMCluster -name "DTUL1ESX01" -type (Get-NBVMClusterTypeByName 'vmware').id
    $Cluster
 }

$vms = Import-Csv $PSScriptRoot\sample-data\virtual-machines.csv
 function add-vmstocluster ($clusterID) {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    $vms| % {
        $clusterID
        $vm = New-NBVM -name $_.name -cluster (Get-NBVMClusterByName 'DTUL1ESX01').id -vcpus 2 -memory 4096
        $vm
        $int = New-NBVMInterface -virtual_machine $vm.id -name 'eth0'
        $ipv4= New-NBIPAddress -address $_.ipv4
        $ipv6= New-NBIPAddress -address $_.ipv6
        Set-NBIPAddressParent -id $ipv4.id -InterFaceType virtualization.vminterface -interface $int.id
        Set-NBIPAddressParent -id $ipv6.id -InterFaceType virtualization.vminterface -interface $int.id
        Set-NBVM -key primary_ip4 -value $ipv4.id -id $vm.id
        Set-NBVM -key primary_ip6 -value $ipv6.id -id $vm.id
        New-NBVMVirtualDisk -virtual_machine $vm.id -name 'os' -description 'description' -size 131072
    }
 }

 function add-ipaddresses {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
     $Devices | ForEach-Object {
        $_|Add-member -MemberType NoteProperty -Name id -Value (Get-nbdevicebyname $_.Name).id
        $_
        "Trying to create interface device"
        $intObj = New-NBDeviceInterface -name eth0 -type 1000base-t -device (get-nbdevicebyid $_.id).id
        $intObj
        "Done creating interface device"
        $ipv4Obj = New-NBIPAddress -address $_.ipv4 -Verbose
        $ipv4Obj
        Set-NBIPAddressParent -id $ipv4Obj.id -interface $intObj.id -InterFaceType dcim.interface
        $ipv6Obj = New-NBIPAddress -address $_.ipv6 -Verbose
        $ipv6Obj
        Set-NBIPAddressParent -id $ipv6Obj.id -interface $intObj.id -InterFaceType dcim.interface
     }
 }

 function reset-ipaddresses {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    $IPAddresses=Get-NBIPAddresses
    $IPAddresses|ForEach-Object {
        Remove-NBIPAddress -id $_.id 
    }
    Get-NBDeviceInterfaces | % { Remove-NBDeviceInterface -id $_.id  }
 }


function add-rirs {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    New-NBRIR -name AFRINIC
    New-NBRIR -name ARIN
    New-NBRIR -name APNIC
    New-NBRIR -name LACNIC
    New-NBRIR -name RIPE
    New-NBRIR -name RFC
    Set-NBRIR -id (Get-NBRIRByName "RFC").id -key description -value "RFC-Documented aggregates"
}

function add-aggregates {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    $Prefixes = $Prefixes |Where-object { 'true' -eq $_.is_aggregate }
    $Prefixes | % {
        $obj = New-NBAggregate -prefix $_.Prefix -rir (Get-NBRIRByName "RFC").id
        Set-NBAggregate -id $obj.id -key tenant -value (Get-NBTenantByName -name $_.tenant).id
    }
}
$Wlans = Import-Csv $PSScriptRoot\sample-data\wlans.csv
function add-wlans {
    Write-Warning "[$($MyInvocation.MyCommand.Name)]"
    $Wlans = Import-Csv $PSScriptRoot\sample-data\wlans.csv
    $Wlans | % {
        $obj = New-NBWirelessLan -SSID $_.ssid
        Set-NBWirelessLan -id $obj.id -key vlan -value (Get-NBVlanByVID $_.vlan).id
        Set-NBWirelessLan -id $obj.id -key tenant -value (Get-NBTenantByName $_.tenant).id
        Set-NBWirelessLan -id $obj.id -key description -value $_.description
    }

}
