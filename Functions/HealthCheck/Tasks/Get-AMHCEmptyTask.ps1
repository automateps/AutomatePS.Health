function Get-AMHCEmptyTask {
    <#
        .SYNOPSIS
            Empty Tasks

        .DESCRIPTION
            Tasks that have no steps defined

        .PARAMETER Tasks
            The tasks to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Tasks
    )

    foreach ($task in ($Tasks | Where-Object {$_.Empty -or [string]::IsNullOrEmpty($_.AML)})) {
        [AMConstructHealthCheckItem]::New($task, "Empty")
    }
}