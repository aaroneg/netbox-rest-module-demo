. $PSScriptRoot\sample-data-functions.ps1 
Test-NBConnection 
add-Tenants  | Out-Null
add-regions  | Out-Null
add-siteGroups  | Out-Null
add-sites  | Out-Null
add-locations  | Out-Null
add-rackroles  | Out-Null
add-racks  | Out-Null
add-contacts  | Out-Null
add-contactroles  | Out-Null
add-deviceroles  | Out-Null
add-manufacturers  | Out-Null
add-platforms  | Out-Null
add-devicetypes  | Out-Null
add-devices  | Out-Null
add-vrfs  | Out-Null
add-vlangroups  | Out-Null
add-vlans  | Out-Null
add-rirs  | Out-Null
add-aggregates  | Out-Null
add-prefixes  | Out-Null
add-ipranges  | Out-Null
add-vmclusterinformation  | Out-Null
add-vmstocluster -clusterid (Get-NBVMClusterByName 'dtulesx01').id  | Out-Null
add-ipaddresses  | Out-Null
add-wlans | Out-Null
