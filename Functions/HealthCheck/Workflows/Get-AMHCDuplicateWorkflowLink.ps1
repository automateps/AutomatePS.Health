function Get-AMHCDuplicateWorkflowLink {
    <#
        .SYNOPSIS
            Duplicate Workflow Links

        .DESCRIPTION
            Workflow links that are duplicated between two items (can cause unexpected multi-execution)

        .PARAMETER Workflows
            The workflows to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Workflows,

        $Repository
    )

    foreach ($workflow in $Workflows) {
        foreach ($linkGroup in ($workflow.Links | Group-Object LinkType,SourceID,DestinationID | Where-Object {$_.Count -gt 1})) {
            $allItems = @($workflow.Items) + @($workflow.Triggers)
            $sourceItem = $allItems | Where-Object {$_.ID -eq $linkGroup.Group[0].SourceID}
            $destinationItem = $allItems | Where-Object {$_.ID -eq $linkGroup.Group[0].DestinationID}
            
            # Get information about the link source
            if ($sourceItem.ConstructType -eq "Evaluation") {
                $sourceHint = "$($sourceItem.ConstructType): $($sourceItem.Expression)"
            } elseif ($sourceItem.ConstructType -eq "Wait") {
                $sourceHint = $sourceItem.ConstructType
            } else {
                $sourceConstruct = $Repository | Where-Object {$_.ID -eq $sourceItem.ConstructID}
                $sourceHint = "$($sourceItem.ConstructType): $($sourceConstruct.Name)"
            }
            
            # Get information about the link destination
            if ($destinationItem.ConstructType -eq "Evaluation") {
                $destinationHint = "$($destinationItem.ConstructType): $($destinationItem.Expression)"
            } elseif ($destinationItem.ConstructType -eq "Wait") {
                $destinationHint = $destinationItem.ConstructType
            } else {
                $destinationConstruct = $Repository | Where-Object {$_.ID -eq $destinationItem.ConstructID}
                $destinationHint = "$($destinationItem.ConstructType): $($destinationConstruct.Name)"
            }

            [AMConstructHealthCheckItem]::New($workflow, "Source: $sourceHint, Destination: $destinationHint")
        }
    }
}