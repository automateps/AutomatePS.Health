function Get-AMHCServerInformation {
    <#
        .SYNOPSIS
            Server Information

        .DESCRIPTION
            Server Information

        .PARAMETER Server
            The server to perform health check against

        .PARAMETER Execution
            The execution server to perform health check against

        .PARAMETER Management
            The management server to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Server,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Execution,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Management
    )

    [AMHealthCheckItem]::new("Server Name:", $Management.ComputerName)
    [AMHealthCheckItem]::new("Cores:", $Execution.TotalCores)
    [AMHealthCheckItem]::new("RAM (KB):", $Execution.TotalRAM)
    [AMHealthCheckItem]::new("Product:", $Server.Product)
    [AMHealthCheckItem]::new("Version:", $Server.Version.ToString())

    $uptimeDaySplit = $Management.Uptime.Split(".")
    $uptimeSubDaySplit = $uptimeDaySplit[1].Split(":")
    $uptimeDays = [int]$uptimeDaySplit[0]
    $uptimeHours = [int]$uptimeSubDaySplit[0]
    $uptimeMinutes = [int]$uptimeSubDaySplit[1]
    $uptimeSeconds = [int]$uptimeSubDaySplit[2]

    [AMHealthCheckItem]::new("Uptime:", "$uptimeDays Days, $uptimeHours Hours, $uptimeMinutes Minutes, $uptimeSeconds Seconds")
    [AMHealthCheckItem]::new("Global Triggering Enabled:", $Execution.GlobalTriggeringEnabled)
    [AMHealthCheckItem]::new("Connected Agents:", $Execution.ConnectedAgentsCount)
    [AMHealthCheckItem]::new("Total Workflow Instances Since Reboot:", $Execution.LifetimeWorkflowInstanceCount)
    [AMHealthCheckItem]::new("Total Task Instances Since Reboot:", $Execution.LifetimeTaskInstanceCount)
    [AMHealthCheckItem]::new("Total Process Instances Since Reboot:", $Execution.LifetimeProcessInstanceCount)
}