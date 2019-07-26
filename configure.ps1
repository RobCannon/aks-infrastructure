#!/usr/bin/pwsh
param
(
    $WorkspaceName = 'default'
)

Import-Module $PSScriptRoot/tfworkspace.psm1 -Force

Push-Location

Write-Host "Configuring workspace $WorkspaceName"

Write-Host "Configuring nginx-ingress"
Set-Location $PSScriptRoot/nginx-ingress
Select-TerraformWorkspace $WorkspaceName
terraform init
terraform apply --auto-approve


Write-Host "Configuring external-dns"
Set-Location $PSScriptRoot/external-dns
Select-TerraformWorkspace $WorkspaceName
terraform init
terraform apply --auto-approve


Write-Host "Configuring cert-manager"
Set-Location $PSScriptRoot/cert-manager
Select-TerraformWorkspace $WorkspaceName
terraform init
terraform apply --auto-approve


Pop-Location