function Get-AMHCUnbuiltWorkflowItem {
    <#
        .SYNOPSIS
            Unbuilt Workflows Items

        .DESCRIPTION
            Workflows with unbuilt items

        .PARAMETER Workflows
            The workflows to perform health check against

        .PARAMETER Repository
            The workflows, tasks, conditions and processes to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Workflows,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Repository
    )

    foreach ($workflow in $Workflows) {
        foreach ($trigger in $workflow.Triggers) {
            if ($trigger.ConstructID -notin $Repository.ID) {
                [AMConstructHealthCheckItem]::New($workflow, "Type: $($trigger.ConstructType)")
            }
        }
        foreach ($item in $workflow.Items) {
            if ($item.ConstructID -notin $Repository.ID -and $item.ConstructType -notin "Evaluation","Wait") {
                [AMConstructHealthCheckItem]::New($workflow, "Type: $($item.ConstructType)")
            }
        }
    }
}