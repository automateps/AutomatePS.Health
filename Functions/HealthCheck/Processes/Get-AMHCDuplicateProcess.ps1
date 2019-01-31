function Get-AMHCDuplicateProcess {
    <#
        .SYNOPSIS
            Duplicate Processes

        .DESCRIPTION
            Processes that have the same Command Line/Working Directory/Environment Variables/Running Context as another process

        .PARAMETER Processes
            The processes to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Processes
    )

    $grouping = $Processes | Group-Object CommandLine,WorkingDirectory,EnvironmentVariables,RunProcessAs
    foreach ($group in ($grouping | Where-Object {$_.Count -gt 1})) {
        foreach ($process in $group.Group) {
            [AMConstructHealthCheckItem]::New($process, "Duplicates: $($group.Group.Name -join " ,")")
        }
    }
}