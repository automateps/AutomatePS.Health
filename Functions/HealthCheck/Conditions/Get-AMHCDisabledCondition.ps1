function Get-AMHCDisabledCondition {
    <#
        .SYNOPSIS
            Disabled Conditions
        
        .DESCRIPTION
            Conditions that are disabled

        .PARAMETER Conditions
            The conditions to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Conditions
    )

    foreach ($condition in ($Conditions | Where-Object {-not $_.Enabled})) {
        [AMConstructHealthCheckItem]::New($condition, "Disabled")
    }
}