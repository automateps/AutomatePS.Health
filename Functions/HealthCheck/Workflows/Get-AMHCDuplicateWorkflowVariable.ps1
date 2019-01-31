function Get-AMHCDuplicateWorkflowVariable {
    <#
        .SYNOPSIS
            Duplicate Workflow Variables

        .DESCRIPTION
            Workflow variables that have the same name within the same workflow

        .PARAMETER Workflows
            The workflows to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Workflows
    )

    foreach ($workflow in $Workflows) {
        foreach ($varGroup in ($workflow.Variables | Group-Object Name | Where-Object {$_.Count -gt 1})) {
            [AMConstructHealthCheckItem]::New($workflow, "Variable name: $($varGroup.Name)")
        }
    }
}