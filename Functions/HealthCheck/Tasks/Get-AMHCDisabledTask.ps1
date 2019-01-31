function Get-AMHCDisabledTask {
    <#
        .SYNOPSIS
            Disabled Tasks

        .DESCRIPTION
            Tasks that are disabled

        .PARAMETER Tasks
            The tasks to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Tasks
    )

    foreach ($task in ($Tasks | Where-Object {-not $_.Enabled})) {
        [AMConstructHealthCheckItem]::New($task, "Disabled")
    }
}