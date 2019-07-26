#!/usr/bin/pwsh
param
(
    $WorkspaceName = 'default'
)

Import-Module $PSScriptRoot/tfworkspace.psm1 -Force

if ($WorkspaceName -eq 'default') {
    $SubscriptionName = 'azure-platform-services-test'
    $ResourceGroupName = 'platform-services-aks-test'
    $ClusterName = 'platform-services-test'
}
elseif ($WorkspaceName -eq 'prod') {
    $SubscriptionName = 'azure-platform-services-prod'
    $ResourceGroupName = 'platform-services-aks-prod'
    $ClusterName = 'platform-services-prod'
}
else {
    $SubscriptionName = 'azure-platform-services-dev'
    $ResourceGroupName = 'platform-services-aks-dev'
    $ClusterName = 'platform-services-dev'
}

if (-not (Get-AzContext | ? { $_.Subscription.Name -eq $SubscriptionName })) {
    Connect-AzAccount -Subscription $SubscriptionName | Out-Null
}

Push-Location cluster
Select-TerraformWorkspace $WorkspaceName
terraform init
terraform apply -auto-approve
Pop-Location

Import-AzAksCredential -ResourceGroupName $ResourceGroupName -Name $ClusterName

helm repo update
kubectl get nodes
