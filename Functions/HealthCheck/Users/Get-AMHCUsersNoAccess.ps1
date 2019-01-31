function Get-AMHCUsersNoAccess {
    <#
        .SYNOPSIS
            Users Without Access

        .DESCRIPTION
            Users that have not been granted system permissions

        .PARAMETER AllUsers
            The users and user groups to perform health check against

        .PARAMETER SystemPermissions
            The system permissions to perform health check against
    #>
    [CmdletBinding()]
    param (
        $AllUsers,

        $SystemPermissions
    )

    $acls = "EditDashboardPermission" ,"EditDefaultPropertiesPermission" ,"EditLicensingPermission" ,"EditPreferencesPermission" ,"EditServerSettingsPermission" ,"ToggleTriggeringPermission" ,"ViewCalendarPermission" ,"ViewDashboardPermission" ,"ViewDefaultPropertiesPermission" ,"ViewLicensingPermission" ,"ViewPreferencesPermission" ,"ViewReportsPermission" ,"ViewServerSettingsPermission"
    $usersWithAccess = @()
    foreach ($permission in $SystemPermissions) {
        $aclHasAllow = $false
        foreach ($acl in $acls) {
            if ($permission.$acl) {
                $aclHasAllow = $true
                break
            }
        }
        if ($aclHasAllow) {
            $object = $AllUsers | Where-Object {$_.ID -eq $permission.GroupID}
            if ($object.Type -eq "User") {
                $usersWithAccess += $object
            } elseif ($object.Type -eq "UserGroup") {
                $usersWithAccess += $AllUsers | Where-Object {$_.ID -in $object.UserIDs -and $_.Type -eq "User"}
            }
        }
    }
    foreach ($user in ($AllUsers | Where-Object {($_.Type -eq "User") -and ($_ -notin $usersWithAccess) -and ($_.Name -ne "Administrator")})) {
        [AMConstructHealthCheckItem]::New($user, "No access")
    }
}