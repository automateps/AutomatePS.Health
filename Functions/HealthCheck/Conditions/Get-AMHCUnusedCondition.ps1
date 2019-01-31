function Get-AMHCUnusedCondition {
    <#
        .SYNOPSIS
            Unused Conditions
        
        .DESCRIPTION
            Conditions that are not used in any workflows

        .PARAMETER Conditions
            The conditions to perform health check against

        .PARAMETER Workflows
            The workflows to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Conditions,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Workflows
    )

    foreach ($condition in $Conditions) {
        if ($Workflows.Items.ConstructID -notcontains $condition.ID -and `
            $Workflows.Triggers.ConstructID -notcontains $condition.ID) {
            [AMConstructHealthCheckItem]::New($condition, "Unused")
        }
    }
}