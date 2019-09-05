function Get-AMHCDuplicateTask {
    <#
        .SYNOPSIS
            Duplicate Tasks

        .DESCRIPTION
            Tasks that have the same AML as another task

        .PARAMETER Tasks
            The tasks to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Tasks
    )

    $grouping = $Tasks | Where-Object {-not [string]::IsNullOrEmpty($_.AML)} | Group-Object AML
    foreach ($group in ($grouping | Where-Object {$_.Count -gt 1})) {
        foreach ($task in $group.Group) {
            [AMConstructHealthCheckItem]::New($task, "Duplicates: $($group.Group.Name -join " ,")")
        }
    }
}