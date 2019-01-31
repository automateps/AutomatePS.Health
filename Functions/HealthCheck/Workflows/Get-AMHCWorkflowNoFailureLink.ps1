function Get-AMHCWorkflowNoFailureLink {
    <#
        .SYNOPSIS
            Workflows without Failure Links

        .DESCRIPTION
            Workflows that don't have any failure links

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
        if ($workflow.Links.LinkType -notcontains "Failure") {
            [AMConstructHealthCheckItem]::New($workflow, "No failure links")
        }
    }
}