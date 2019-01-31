function Get-AMHCWorkflowEvaluationObjectNonResultLink {
    <#
        .SYNOPSIS
            Workflows with Non-Result Links for Evaluation Objects

        .DESCRIPTION
            Workflow evaluation objects that have any non-result links

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
        foreach ($item in ($workflow.Items | Where-Object {$_.ConstructType -eq "Evaluation"})) {
            $links = $workflow.Links | Where-Object {$_.SourceID -eq $item.ID}
            if ($links.LinkType -contains "Success" -or $links.LinkType -contains "Failure") {
                [AMConstructHealthCheckItem]::New($workflow, "Evaluation: $($item.Expression)")
            }
        }
    }
}