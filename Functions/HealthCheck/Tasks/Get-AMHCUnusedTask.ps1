function Get-AMHCUnusedTask {
    <#
        .SYNOPSIS
            Unused Tasks

        .DESCRIPTION
            Tasks that are not used in any workflows

        .PARAMETER Tasks
            The tasks to perform health check against

        .PARAMETER Workflows
            The workflows to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Tasks,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Workflows
    )

    foreach ($task in $Tasks) {
        if ($Workflows.Items.ConstructID -notcontains $task.ID) {
            [AMConstructHealthCheckItem]::New($task, "Unused")
        }
    }
}