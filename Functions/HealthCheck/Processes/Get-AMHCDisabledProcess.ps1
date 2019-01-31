function Get-AMHCDisabledProcess {
    <#
        .SYNOPSIS
            Disabled Processes

        .DESCRIPTION
            Processes that are disabled

        .PARAMETER Processes
            The processes to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Processes
    )

    foreach ($process in ($Processes | Where-Object {-not $_.Enabled})) {
        [AMConstructHealthCheckItem]::New($process, "Disabled")
    }
}