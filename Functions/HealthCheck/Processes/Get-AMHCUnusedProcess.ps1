function Get-AMHCUnusedProcess {
    <#
        .SYNOPSIS
            Unused Processes

        .DESCRIPTION
            Processes that are not used in any workflows

        .PARAMETER Processes
            The processes to perform health check against

        .PARAMETER Workflows
            The workflows to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Processes,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Workflows
    )

    foreach ($process in $Processes) {
        if ($Workflows.Items.ConstructID -notcontains $process.ID) {
            [AMConstructHealthCheckItem]::New($process, "Unused")
        }
    }
}