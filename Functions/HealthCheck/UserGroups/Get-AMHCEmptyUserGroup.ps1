function Get-AMHCEmptyUserGroup {
    <#
        .SYNOPSIS
            Empty User Groups

        .DESCRIPTION
            User groups that don't have any members

        .PARAMETER UserGroups
            The user groups to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $UserGroups
    )

    foreach ($userGroup in $UserGroups) {
        if ($userGroup.UserIDs.Count -eq 0) {
            [AMConstructHealthCheckItem]::New($userGroup, "Empty")
        }
    }
}