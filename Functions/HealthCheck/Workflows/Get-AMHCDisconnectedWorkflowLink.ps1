function Get-AMHCDisconnectedWorkflowLink {
    <#
        .SYNOPSIS
            Disconnected Workflow Links

        .DESCRIPTION
            Workflow links that have one or both ends disconnected

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
        foreach ($link in $workflow.Links) {
            if (($null -eq $link.SourceID) -or ($null -eq $link.DestinationID)) {
                [AMConstructHealthCheckItem]::New($workflow, "Link type: $($link.LinkType)")
            } elseif (-not (($link.SourceID -in @($workflow.Triggers.ID) + @($workflow.Items.ID)) -and
                     ($link.DestinationID -in @($workflow.Triggers.ID) + @($workflow.Items.ID)))) {
                [AMConstructHealthCheckItem]::New($workflow, "Link type: $($link.LinkType)")
            }
        }
    }
}