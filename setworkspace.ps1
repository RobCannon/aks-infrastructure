#!/usr/bin/pwsh
param
(
    $WorkspaceName = 'default'
)

Import-Module $PSScriptRoot/tfworkspace.psm1 -Force

Push-Location

Set-Location $PSScriptRoot/cluster
Select-TerraformWorkspace $WorkSpaceName

Set-Location $PSScriptRoot/nginx-ingress
Select-TerraformWorkspace $WorkSpaceName

Set-Location $PSScriptRoot/external-dns
Select-TerraformWorkspace $WorkSpaceName

Set-Location $PSScriptRoot/cert-manager
Select-TerraformWorkspace $WorkSpaceName

Pop-Location
