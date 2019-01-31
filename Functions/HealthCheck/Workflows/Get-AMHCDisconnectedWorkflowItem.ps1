function Get-AMHCDisconnectedWorkflowItem {
    <#
        .SYNOPSIS
            Disconnected Workflow Items

        .DESCRIPTION
            Workflow items that don't have any connected links

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

        $Repository
    )

    foreach ($workflow in $Workflows) {
        $allItems = @($workflow.Triggers) + @($workflow.Items)
        if (($allItems | Measure-Object).Count -gt 1) {
            foreach ($trigger in $workflow.Triggers) {
                if ($workflow.Links.SourceID -notcontains $trigger.ID -and `
                    $workflow.Links.DestinationID -notcontains $trigger.ID) {
                    $repoItem = $Repository | Where-Object {$_.ID -eq $trigger.ConstructID}
                    [AMConstructHealthCheckItem]::New($workflow, "$($trigger.TriggerType): $($repoItem.Name)")
                }
            }
            foreach ($item in $workflow.Items) {
                if ($workflow.Links.SourceID -notcontains $item.ID -and `
                    $workflow.Links.DestinationID -notcontains $item.ID) {
                    $repoItem = $Repository | Where-Object {$_.ID -eq $item.ConstructID}
                    [AMConstructHealthCheckItem]::New($workflow, "$($item.ConstructType): $($repoItem.Name)")
                }
            }
        }
    }
}