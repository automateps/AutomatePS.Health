function Get-AMHCEmptyAgentGroup {
    <#
        .SYNOPSIS
            Empty Agent Groups

        .DESCRIPTION
            Agent groups that don't have any members

        .PARAMETER AgentGroups
            The agent groups to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $AgentGroups
    )

    foreach ($agentGroup in $AgentGroups) {
        if ($agentGroup.AgentIDs.Count -eq 0) {
            [AMConstructHealthCheckItem]::New($agentGroup, "Empty")
        }
    }
}