function Get-AMHCDisabledUserGroup {
    <#
        .SYNOPSIS
            Disabled User Groups

        .DESCRIPTION
            User groups that are disabled

        .PARAMETER UserGroups
            The user groups to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $UserGroups
    )

    foreach ($userGroup in ($UserGroups | Where-Object {-not $_.Enabled})) {
        [AMConstructHealthCheckItem]::New($userGroup, "Disabled")
    }
}