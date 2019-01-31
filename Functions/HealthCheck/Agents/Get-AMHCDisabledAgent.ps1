function Get-AMHCDisabledAgent {
    <#
        .SYNOPSIS
            Disabled Agents

        .DESCRIPTION
            Agents that are disabled

        .PARAMETER Agents
            The agents to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Agents
    )

    foreach ($agent in ($Agents | Where-Object {-not $_.Enabled})) {
        [AMConstructHealthCheckItem]::New($agent, "Disabled")
    }
}