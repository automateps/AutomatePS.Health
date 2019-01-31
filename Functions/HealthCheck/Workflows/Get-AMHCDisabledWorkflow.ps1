function Get-AMHCDisabledWorkflow {
    <#
        .SYNOPSIS
            Disabled Workflows
        
        .DESCRIPTION
            Workflows that are disabled

        .PARAMETER Workflows
            The workflows to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Workflows
    )

    foreach ($workflow in ($Workflows | Where-Object {-not $_.Enabled})) {
        [AMConstructHealthCheckItem]::New($workflow, "Disabled")
    }
}