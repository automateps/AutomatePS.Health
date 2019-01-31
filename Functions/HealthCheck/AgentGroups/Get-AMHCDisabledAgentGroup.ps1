function Get-AMHCDisabledAgentGroup {
    <#
        .SYNOPSIS
            Disabled Agent Groups

        .DESCRIPTION
            Agent groups that are disabled

        .PARAMETER AgentGroups
            The agent groups to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $AgentGroups
    )

    foreach ($agentGroup in ($AgentGroups | Where-Object {-not $_.Enabled})) {
        [AMConstructHealthCheckItem]::New($agentGroup, "Disabled")
    }
}