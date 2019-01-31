function Get-AMHCDisabledWorkflowItem {
    <#
        .SYNOPSIS
            Disabled Workflow Items

        .DESCRIPTION
            Workflow items that are disabled

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
        foreach ($trigger in $workflow.Triggers) {
            if (-not $trigger.Enabled) {
                $repoItem = $Repository | Where-Object {$_.ID -eq $trigger.ConstructID}
                [AMConstructHealthCheckItem]::New($workflow, "$($trigger.TriggerType): $($repoItem.Name)")
            }
        }
        foreach ($item in $workflow.Items) {
            if (-not $item.Enabled) {
                $repoItem = $Repository | Where-Object {$_.ID -eq $item.ConstructID}
                [AMConstructHealthCheckItem]::New($workflow, "$($item.ConstructType): $($repoItem.Name)")
            }
        }
    }
}