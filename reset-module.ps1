Remove-Module -Name netbox-rest-module -ErrorAction SilentlyContinue -Force
Import-Module -Name netbox-rest-module -Force
. $PSScriptRoot\init.ps1
