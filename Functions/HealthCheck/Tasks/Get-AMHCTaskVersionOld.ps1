function Get-AMHCTaskVersionOld {
    <#
        .SYNOPSIS
            Old Task Versions

        .DESCRIPTION
            Tasks whose version doesn't match the server version

        .PARAMETER Tasks
            The tasks to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Tasks
    )

    foreach ($task in $Tasks) {
        try {
            $xml = [xml]$task.AML
        } catch {
            # Task_AML_Not_XML health check will report this
            continue
        }
        $taskConnection = Get-AMConnection -Connection $task.ConnectionAlias
        switch ($taskConnection.Version.Major) {
            10 {$taskVersion = $xml.AMTASK.AMTASKHEAD.TASKINFO.TASKVERSION}
            11 {$taskVersion = $xml.AutomateTask.TaskInfo.Version.TaskVersion}
        }
        if ([Version]$taskVersion -ne $taskConnection.Version) {
            [AMConstructHealthCheckItem]::New($task, "Task version: $taskVersion")
        }
    }
}