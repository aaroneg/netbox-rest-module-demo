$Tenants=Import-Csv -Path $PSScriptRoot\sample-data\tenants.csv
$Regions=Import-Csv -Path $PSScriptRoot\sample-data\regions.csv
$SiteGroups=Import-Csv -Path $PSScriptRoot\sample-data\site-groups.csv
$Sites=Import-Csv -Path $PSScriptRoot\sample-data\Sites.csv
$Locations=Import-Csv -Path $PSScriptRoot\sample-data\locations.csv
$RackRoles=Import-csv -Path $PSScriptRoot\sample-data\rack-roles.csv
$Racks=Import-csv -Path $PSScriptRoot\sample-data\racks.csv

. $PSScriptRoot\init.ps1
function add-Tenants {
    $groups=$Tenants | Select-Object -Unique -ExpandProperty group
    foreach ($item in $groups) {
        New-NBTenantGroup -name $item
    }
    $AllTenantGroups=Get-NBTenantGroups
    foreach ($Tenant in $Tenants) {
        $obj = New-NBTenant -name $Tenant.name
        Set-NBTenant -id $obj.id -key group -value ($AllTenantGroups | Where-Object {$_.Name -eq  $Tenant.group}).id
    }
}

function add-regions {
    $Regions| ForEach-Object {
        New-NBRegion -name $_.Name
    }
    $AllRegions=Get-NBRegions
    Foreach($region in $Regions) {
        if ($region.parent) {
            Set-NBRegion -id ($AllRegions|Where-Object {$_.name -eq $region.name}).id -key parent -value ($AllRegions|Where-Object {$_.name -eq $region.parent}).id
        }
    }
}

function add-siteGroups {
    $SiteGroups | ForEach-Object {
        $obj = New-NBSiteGroup -name $_.name
        Set-NBSiteGroup -id $obj.id -key description -value $_.description
    }
    $AllSiteGroups = Get-NBSiteGroups
    foreach ($sitegroup in $SiteGroups) {
        if ($sitegroup.parent) {
            Set-NBSiteGroup -id ($AllSiteGroups|Where-Object {$_.name -eq $sitegroup.name}).id -key parent -value ($AllSiteGroups|Where-Object{$_.name -eq $sitegroup.parent}).id
        }
    }
}

function add-sites {
    $AllRegions=Get-NBRegions
    $AllSiteGroups=Get-NBSiteGroups
    foreach ($site in $Sites) {
        $obj = New-NBSite -name $site.name -status $site.status
        Set-NBSite -id $obj.id -key region -value ($AllRegions | Where-Object {$_.name -eq $site.region}).id
        Set-NBSite -id $obj.id -key group -value ($AllSiteGroups | Where-Object {$_.name -eq $site.sitegroup}).id
        Set-NBSite -id $obj.id -key facility -value $site.facility
        Set-NBSite -id $obj.id -key time_zone -value $site.timezone
        Set-NBSite -id $obj.id -key description -value $site.description
    }
}

function add-locations {
    foreach ($location in $Locations) {
        $obj = New-NBLocation -name $location.name -siteID (Find-NBSitesByName -name $location.site)[0].id
        Set-NBLocation -id $obj.id -key tenant -value (Find-NBTenantsByName -name $location.tenant)[0].id
        Set-NBLocation -id $obj.id -key description -value $location.description
        if ($location.parent.length -gt 1) {
            Set-NBLocation -id $obj.id -key parent -value (Find-NBLocationsByName -name $location.parent)[0].id
        }
        #Read-Host -Prompt "Press enter to proceed"
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
        $obj = New-NBRack -name $_.name -siteID (Find-NBSitesByName -name $_.site)[0].id -locationID (Find-NBLocationsByName -name $_.location)[0].id -Verbose
        Set-NBRack -id $obj.id -key role -value (Find-NBRackRolesByName -name $_.role)[0].id
        Set-NBRack -id $obj.id -key tenant -value(Find-NBTenantsByName -name $_.tenant)[0].id        
    }
}