function Get-AMHCOfflineAgent {
    <#
        .SYNOPSIS
            Offline Agents

        .DESCRIPTION
            Agents that are not connected to the management server

        .PARAMETER Agents
            The agents to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Agents
    )

    foreach ($agent in ($Agents | Where-Object {-not $_.Online})) {
        [AMConstructHealthCheckItem]::New($agent, "Offline")
    }
}