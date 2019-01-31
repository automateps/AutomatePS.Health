function Get-AMHCUnusedAgent {
    <#
        .SYNOPSIS
            Unused Agents

        .DESCRIPTION
            Agents that are not used in any workflows, or are members of any agent groups

        .PARAMETER Agents
            The agents to perform health check against

        .PARAMETER AgentGroups
            The agent groups to perform health check against

        .PARAMETER Workflows
            The workflows to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Agents,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $AgentGroups,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Workflows
    )

    foreach ($agent in $Agents) {
        if ($Workflows.Triggers.AgentID -notcontains $agent.ID -and `
            $Workflows.Items.AgentID -notcontains $agent.ID -and `
            $AgentGroups.AgentIDs -notcontains $agent.ID) {
            [AMConstructHealthCheckItem]::New($agent, "Unused")
        }
    }
}