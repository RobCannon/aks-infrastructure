function Get-TerraformWorkspace {
    $workspaces = terraform workspace list
    $workspaces | % {
        if ($_ -match '([* ]) (\w+)') {
            [pscustomobject]@{
                WorkspaceName = $matches[2]
                Selected      = $matches[1] -eq '*'
            }
        }
    }
}

function Select-TerraformWorkspace {
    param
    (
        $WorkspaceName
    )

    $workspace = Get-TerraformWorkspace | ? WorkspaceName -eq $WorkspaceName
    if ($workspace) {
        if (-not $workspace.Selected) {
            terraform workspace select $WorkspaceName
        }
    }
    else {
        terraform workspace new $WorkspaceName
    }
}

Export-ModuleMember -Function *