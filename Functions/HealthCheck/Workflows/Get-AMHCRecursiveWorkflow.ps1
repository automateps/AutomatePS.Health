function Get-AMHCRecursiveWorkflow {
    <#
        .SYNOPSIS
            Recursive Workflows

        .DESCRIPTION
            Workflows that contain themselves as an item (can cause infinite looping/possible server crash if exit condition does not exist)

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
        if ($workflow.Items.ConstructID -contains $workflow.ID) {
            [AMConstructHealthCheckItem]::New($workflow, "Recursive")
        }
    }
}