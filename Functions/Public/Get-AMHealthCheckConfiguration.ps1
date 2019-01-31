function Get-AMHealthCheckConfiguration {
    <#
        .SYNOPSIS
            Gets the configuration for the health check

        .DESCRIPTION
            Get-AMHealthCheckConfiguration pulls the health check configuration from config.json
    #>
    [CmdletBinding()]
    param ()

    $moduleRoot = (Get-Item -Path $PSCommandPath).Directory.Parent.Parent
    $config = Get-Content -Path "$($moduleRoot.FullName)\Config\config.json" | ConvertFrom-Json
    return $config
}