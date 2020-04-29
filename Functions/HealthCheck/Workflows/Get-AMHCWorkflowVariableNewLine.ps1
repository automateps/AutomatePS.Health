function Get-AMHCWorkflowVariableNewLine {
    <#
        .SYNOPSIS
            Workflow Variable names with new line character

        .DESCRIPTION
            Workflow variables that have a new line character in the name

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
        foreach ($variable in $workflow.Variables) {
            if ($variable.Name -like "*`n*") {
                [AMConstructHealthCheckItem]::New($workflow, "Variable name: $($variable.Name)")
            }
        }
    }
}