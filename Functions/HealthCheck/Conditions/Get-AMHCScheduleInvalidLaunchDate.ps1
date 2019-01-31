function Get-AMHCScheduleInvalidLaunchDate {
    <#
        .SYNOPSIS
            Invalid Schedule Launch Dates

        .DESCRIPTION
            Schedules that have not computed a next launch date

        .PARAMETER Conditions
            The conditions to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Conditions
    )

    foreach ($condition in ($Conditions | Where-Object {$_.TriggerType -eq "Schedule" -and $_.NextLaunchDate -eq ''})) {
        [AMConstructHealthCheckItem]::New($condition, "Next Launch Date not set")
    }
}