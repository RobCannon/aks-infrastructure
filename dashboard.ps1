#!/usr/bin/pwsh
param
(
    $WorkspaceName = 'default'
)

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
az account set --subscription $SubscriptionName
az aks browse --resource-group $ResourceGroupName --name $ClusterName