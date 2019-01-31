function Get-AMHCWorkflowNoTrigger {
    <#
        .SYNOPSIS
            Workflows without Triggers or not Subworkflow

        .DESCRIPTION
            Workflows that don't have any triggers, or are not subworkflows within another workflow

        .PARAMETER Workflows
            The workflows to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Workflows
    )

    $noTriggers = $Workflows | Where-Object {($_.Triggers | Measure-Object).Count -eq 0}
    foreach ($workflow in $noTriggers) {
        if ($Workflows.Items.ConstructID -notcontains $workflow.ID) {
            [AMConstructHealthCheckItem]::New($workflow, "No triggers")
        }
    }
}