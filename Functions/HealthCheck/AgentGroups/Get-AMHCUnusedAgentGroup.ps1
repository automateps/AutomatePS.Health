function Get-AMHCUnusedAgentGroup {
    <#
        .SYNOPSIS
            Unused Agent Groups

        .DESCRIPTION
            Agent groups that are not used in any workflows

        .PARAMETER AgentGroups
            The agent groups to perform health check against

        .PARAMETER Workflows
            The workflows to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $AgentGroups,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Workflows
    )

    foreach ($agentGroup in $AgentGroups) {
        if ($Workflows.Triggers.AgentID -notcontains $agentGroup.ID -and `
            $Workflows.Items.AgentID -notcontains $agentGroup.ID) {
            [AMConstructHealthCheckItem]::New($agentGroup, "Unused")
        }
    }
}