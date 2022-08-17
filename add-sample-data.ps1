$Tenants=Import-Csv -Path $PSScriptRoot\sample-data\tenants.csv
$Regions=Import-Csv -Path $PSScriptRoot\sample-data\regions.csv
$SiteGroups=Import-Csv -Path $PSScriptRoot\sample-data\site-groups.csv
$Sites=Import-Csv -Path $PSScriptRoot\sample-data\Sites.csv
$Locations=Import-Csv -Path $PSScriptRoot\sample-data\locations.csv
$RackRoles=Import-csv -Path $PSScriptRoot\sample-data\rack-roles.csv
$Racks=Import-csv -Path $PSScriptRoot\sample-data\racks.csv
$Contacts=Import-Csv -Path $PSScriptRoot\sample-data\contacts.csv
$DeviceTypes=Import-Csv -Path $PSScriptRoot\sample-data\device-types.csv


. $PSScriptRoot\init.ps1
function add-Tenants {
    $groups=$Tenants | Select-Object -Unique -ExpandProperty group
    foreach ($item in $groups) {
        New-NBTenantGroup -name $item
    }
    foreach ($Tenant in $Tenants) {
        $obj = New-NBTenant -name $Tenant.name
        Set-NBTenant -id $obj.id -key group -value (Get-NBTenantGroupByName $Tenant.group).id
    }
}

function add-regions {
    $Regions| ForEach-Object {
        New-NBRegion -name $_.name
    }
    $Regions| ForEach-Object {
        if($_.parent) {
            Set-NBRegion -id (Get-NBRegionByName -name $_.name).id -key parent -value (Get-NBRegionByName -name $_.parent).id
        }
    }
}

function add-siteGroups {
    $SiteGroups | ForEach-Object {
        $obj = New-NBSiteGroup -name $_.name
        Set-NBSiteGroup -id $obj.id -key description -value $_.description
    }
    $SiteGroups | ForEach-Object {
        if ($_.parent) {
            Set-NBSiteGroup -id (Get-NBSiteGroupByName $_.name).id -key parent -value (Get-NBSiteGroupByName -name $_.parent).id
        }
    }
}

function add-sites {
    foreach ($site in $Sites) {
        $obj = New-NBSite -name $site.name -status $site.status
        Set-NBSite -id $obj.id -key region -value (Get-NBRegionByName $site.region).id
        Set-NBSite -id $obj.id -key group -value (Get-NBSiteGroupByName $site.sitegroup).id
        Set-NBSite -id $obj.id -key facility -value $site.facility
        Set-NBSite -id $obj.id -key time_zone -value $site.timezone
        Set-NBSite -id $obj.id -key description -value $site.description
    }
}

function add-locations {
    foreach ($location in $Locations) {
        $obj = New-NBLocation -name $location.name -siteID (Get-NBSiteByName -name $location.site).id
        Set-NBLocation -id $obj.id -key tenant -value (Get-NBTenantByName -name $location.tenant).id
        Set-NBLocation -id $obj.id -key description -value $location.description
    }
    foreach ($location in $Locations){
        if ($location.parent) {
            Set-NBLocation -id (Get-NBLocationByName -name $location.name) -key parent -value (Get-NBLocationByName -name $location.parent).id
        }
    }
}
function add-rackroles {
    $RackRoles | ForEach-Object {
        $obj = New-NBRackRole -name $_.Name
        Set-NBRackRole -id $obj.id -key color -value $_.color
    }
}

function add-racks {
    $Racks | ForEach-Object {
        $obj = New-NBRack -name $_.name -siteID (Get-NBSiteByName -name $_.site).id -locationID (Get-NBLocationByName -name $_.location).id
        Set-NBRack -id $obj.id -key role -value (Get-NBRackRoleByName -name $_.role).id
        Set-NBRack -id $obj.id -key tenant -value(Get-NBTenantByName -name $_.tenant).id        
    }
}

function add-contacts {
    $ContactGroups = $Contacts | Select-Object -ExpandProperty group -Unique
    foreach ($item in $ContactGroups) {
        New-NBContactGroup -name $item
    }
    $Contacts | ForEach-Object {
        $_.name
        $obj = New-NBContact -name $_.name
        Set-NBContact -id $obj.id -key title -value $_.title
        Set-NBContact -id $obj.id -key phone -value $_.phone
        Set-NBContact -id $obj.id -key email -value $_.email
        Set-NBContact -id $obj.id -key address -value $_.address
        Set-NBContact -id $obj.id -key link -value $_.link
        Set-NBContact -id $obj.id -key group -value (Get-NBContactGroupByName -name  $_.group).id
    }
}

function add-contactroles {
    New-NBContactRole -name "Technician"
}

function add-deviceroles {
    New-NBDeviceRole -name "server" -color "2568da"
    New-NBDeviceRole -name "switch" -color "65d60e"
    New-NBDeviceRole -name "power" -color "efe410"
}

function add-manufacturers {
    New-NBManufacturer -name "Microsoft"
    New-NBManufacturer -name "Apple"
    New-NBManufacturer -name "Cisco"
    New-NBManufacturer -name "Ruckus"
    New-NBManufacturer -name "Juniper"
    New-NBManufacturer -name "Dell"
    New-NBManufacturer -name "CheapNetworks"
}

function add-platforms {
    New-NBDevicePlatform -name "Linux"
    $obj = New-NBDevicePlatform -name "Windows"
    Set-NBDevicePlatform -id $obj.id -key manufacturer -value (Get-NBManufacturerByName -name "microsoft").id

}

function add-devicetypes {
    $DeviceTypes|ForEach-Object {
        $obj=New-NBDeviceType -manufacturerID (Get-NBManufacturerByName $_.manufacturer).id -model $_.model
        Set-NBDeviceType -id $obj.id -key u_height -value $_.u_height
        Set-NBDeviceType -id $obj.id -key is_full_depth -value $_.is_full_depth
        Set-NBDeviceType -id $obj.id -key comments -value $_.comments
        if ($_.subdevice_role) {
            Set-NBDeviceType -id $obj.id -key subdevice_role -value $_.subdevice_role
        }
    }
}

function add-devices {

}