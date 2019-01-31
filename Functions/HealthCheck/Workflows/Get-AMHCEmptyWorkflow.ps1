function Get-AMHCEmptyWorkflow {
    <#
        .SYNOPSIS
            Empty Workflows

        .DESCRIPTION
            Workflows that don't contain any items

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
        if ($workflow.Items.Count -eq 0) {
            [AMConstructHealthCheckItem]::New($workflow, "Empty")
        }
    }
}