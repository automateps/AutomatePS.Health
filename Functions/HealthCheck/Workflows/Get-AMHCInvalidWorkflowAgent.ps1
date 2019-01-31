function Get-AMHCInvalidWorkflowAgent {
    <#
        .SYNOPSIS
            Invalid Workflow Agent References
        
        .DESCRIPTION
            Workflows that have items that reference non-existent agents (can happen when an agent is removed/added during upgrade)

        .PARAMETER Workflows
            The workflows to perform health check against

        .PARAMETER AllAgents
            The agents and agent groups to perform the health check against

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
        $AllAgents,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Repository
    )

    foreach ($workflow in $Workflows) {
        foreach ($trigger in $workflow.Triggers) {
            if ($trigger.AgentID -notin $AllAgents.ID -and $trigger.TriggerType -ne "Schedule") {
                $repoItem = $Repository | Where-Object {$_.ID -eq $trigger.ConstructID}
                [AMConstructHealthCheckItem]::New($workflow, "$($trigger.ConstructType): $($repoItem.Name)")
            }
        }
        foreach ($item in $workflow.Items) {
            if ($item.AgentID -notin $AllAgents.ID -and $item.ConstructType -notin "Workflow","Evaluation","Wait") {
                $repoItem = $Repository | Where-Object {$_.ID -eq $item.ConstructID}
                [AMConstructHealthCheckItem]::New($workflow, "$($item.ConstructType): $($repoItem.Name)")
            }
        }
    }
}