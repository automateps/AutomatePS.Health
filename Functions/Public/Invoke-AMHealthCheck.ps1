function Invoke-AMHealthCheck {
    <#
        .SYNOPSIS
            Executes a health check against Automate Enterprise

        .DESCRIPTION
            Invoke-AMHealthCheck dynamically loads health checks from the Plugins folder and performs them against Automate Enterprise

        .PARAMETER CustomConfigPath
            The path to a JSON file containing health check configuration settings.  This file can include new, custom health checks, or modifications to built in health checks.

        .PARAMETER Connection
            The Automate Enterprise management server.
    #>
    [CmdletBinding()]
    param (
        [ValidateScript({Test-Path -Path $_})]
        $CustomConfigPath,

        [ValidateNotNullOrEmpty()]
        $Connection
    )
    
    if ($PSBoundParameters.ContainsKey("Connection")) {
        $Connection = Get-AMConnection -Connection $connection
    } else {
        $Connection = Get-AMConnection
    }
    $objectCache = @{}
    $results = @()
    foreach ($c in $Connection) {
        Write-Verbose "Server $($c.Alias): Querying objects"
        $objectCache.Add($c.Alias, @{})
        $objectCache[$c.Alias].Add("Workflows",    (Get-AMWorkflow -Connection $c.Alias))
        $objectCache[$c.Alias].Add("Tasks",        (Get-AMTask -Connection $c.Alias))
        $objectCache[$c.Alias].Add("Conditions",   (Get-AMCondition -Connection $c.Alias))
        $objectCache[$c.Alias].Add("Processes",    (Get-AMProcess -Connection $c.Alias))
        $objectCache[$c.Alias].Add("Agents",       (Get-AMAgent -Connection $c.Alias))
        $objectCache[$c.Alias].Add("SystemAgents", (Get-AMSystemAgent -Connection $c.Alias))
        $objectCache[$c.Alias].Add("AgentGroups",  (Get-AMAgentGroup -Connection $c.Alias))
        $objectCache[$c.Alias].Add("Users",        (Get-AMUser -Connection $c.Alias))
        $objectCache[$c.Alias].Add("UserGroups",   (Get-AMUserGroup -Connection $c.Alias))
        $objectCache[$c.Alias].Add("SystemPermissions", (Get-AMSystemPermission -Connection $c.Alias))
        $objectCache[$c.Alias].Add("Server",       (Get-AMServer -Connection $c.Alias))
        $objectCache[$c.Alias].Add("Execution",    (Get-AMServer -Type Execution -Connection $c.Alias))
        $objectCache[$c.Alias].Add("Management",   (Get-AMServer -Type Management -Connection $c.Alias))
        $objectCache[$c.Alias].Add("AllAgents",    @($objectCache[$c.Alias].Agents) + @($objectCache[$c.Alias].SystemAgents) + @($objectCache[$c.Alias].AgentGroups))
        $objectCache[$c.Alias].Add("AllUsers",     @($objectCache[$c.Alias].Users) + @($objectCache[$c.Alias].UserGroups))
        $objectCache[$c.Alias].Add("Repository",   @($objectCache[$c.Alias].Workflows) + @($objectCache[$c.Alias].Tasks) + @($objectCache[$c.Alias].Conditions) + @($objectCache[$c.Alias].Processes))

        if ($CustomConfigPath) {
            $config = Get-AMHealthCheckConfiguration -CustomConfigPath $CustomConfigPath
        } else {
            $config = Get-AMHealthCheckConfiguration
        }
        foreach ($category in ($config.Categories | Where-Object {$_.Enabled} | Sort-Object -Property "SortOrder")) {
            foreach ($healthCheck in ($category.HealthChecks | Where-Object {$_.Enabled} | Sort-Object -Property "SortOrder")) {
                if (Get-Command -Name $healthCheck.Function -ErrorAction SilentlyContinue) {
                    $parameters = (Get-Command $healthCheck.Function).Parameters.Keys | Where-Object {($_ -notin [System.Management.Automation.PSCmdlet]::CommonParameters) -and ($_ -notin [System.Management.Automation.PSCmdlet]::OptionalCommonParameters)}
                    $splat = @{}
                    foreach ($parameter in $parameters) {
                        if ($objectCache[$c.Alias].ContainsKey($parameter)) {
                            $splat.Add($parameter, $objectCache[$c.Alias][$parameter])
                        } else {
                            Write-Warning "Could not find data for parameter -$parameter in health check function $($healthCheck.Function)!"
                        }
                    }
                    Write-Verbose "Server $($c.Alias): Running health check $($category.Name) - $($healthCheck.Name)"
                    $output = Invoke-Expression -Command ($healthCheck.Function + ' @splat')
                    if ($healthCheck.ShowCount) {
                        $healthCheckResultCount = ($output | Measure-Object).Count
                        $healthCheckName = "$($healthCheck.Name) : $healthCheckResultCount Objects"
                    } else {
                        $healthCheckName = $healthCheck.Name
                    }
                    $results += [AMHealthCheckResult]::new($category.Name, $healthCheckName, $healthCheck.Description, $healthCheck.Function, $healthCheck.Importance, $output, $c.Alias)
                } else {
                    Write-Warning "Could not find health check $($healthCheck.Function)!"
                }
            }
        }
    }
    return $results
}