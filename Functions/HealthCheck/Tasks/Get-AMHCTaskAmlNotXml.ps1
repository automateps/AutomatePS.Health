function Get-AMHCTaskAmlNotXml {
    <#
        .SYNOPSIS
            Tasks with AML non-comforming with XML

        .DESCRIPTION
            Tasks with AML that cannot be converted to XML (this generally doesn't cause issues with Automate, but makes other AML health checks difficult)

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
            [xml]$task.AML | Out-Null
        } catch {
            [AMConstructHealthCheckItem]::New($task, "Invalid XML")
        }
    }
}