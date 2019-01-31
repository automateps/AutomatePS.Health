function Invoke-AMHealthCheck {
    <#
        .SYNOPSIS
            Executes a health check against Automate Enterprise

        .DESCRIPTION
            Invoke-AMHealthCheck dynamically loads health checks from the Plugins folder and performs them against Automate Enterprise

        .PARAMETER OutputPath
            The location to save the health check results

        .PARAMETER OutputFormat
            The format to save the health check results in: HTML, Word, Text, XML

        .PARAMETER Connection
            The Automate Enterprise management server.
    #>
    [CmdletBinding()]
    param (
        [ValidateScript({Test-Path -Path $_})]
        $OutputPath,

        [ValidateSet("HTML","Word","Text","XML")]
        $OutputFormat = "HTML",

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

        $config = Get-AMHealthCheckConfiguration
        foreach ($category in ($config.Categories | Where-Object {$_.Enabled} | Sort-Object -Property "SortOrder")) {
            foreach ($healthCheck in ($category.HealthChecks | Where-Object {$_.Enabled} | Sort-Object -Property "SortOrder")) {
                if (Get-Command -Name $healthCheck.Function -ErrorAction SilentlyContinue) {
                    $parameters = (Get-Command $healthCheck.Function).Parameters.Keys | Where-Object {($_ -notin [System.Management.Automation.PSCmdlet]::CommonParameters) -and ($_ -notin [System.Management.Automation.PSCmdlet]::OptionalCommonParameters)}
                    $splat = @{}
                    foreach ($parameter in $parameters) {
                        if ($objectCache[$c.Alias].ContainsKey($parameter)) {
                            $splat.Add($parameter, $objectCache[$c.Alias][$parameter])
                        } else {
                            Write-Warning "Could not find data for parameter -$parameter in health check $($healthCheck.Function)!"
                        }
                    }
                    Write-Verbose "Server $($c.Alias): Running health check $($category.Name) - $($healthCheck.Function)"
                    $output = Invoke-Expression -Command ($healthCheck.Function + ' @splat')
                    $results += [AMHealthCheckResult]::new($category.Name, $healthCheck.Function, $output, $c.Alias)
                } else {
                    Write-Warning "Could not find health check $($healthCheck.Function)!"
                }
            }
        }
        if ($PSBoundParameters.ContainsKey("OutputPath")) {
            if (Test-Path -Path $OutputPath) {
                $countedHealthChecks = $config.Categories.HealthChecks | Where-Object {[AMHealthCheckImportance]$_.Importance -ge [AMHealthCheckImportance]$config.CategoryCountInformationLevel}
                Document "Automate_Health_Check_$($c.Alias.Replace(":","_"))_$(Get-Date -Format "yyyyMMddhhmmss")" {
                    Style -Name "InformationHealthCheckHeader" -Size 12 -Color Gray
                    Style -Name "WarningHealthCheckHeader" -Size 12 -Color Orange
                    Style -Name "ErrorHealthCheckHeader" -Size 12 -Color Red
                    DocumentOption -Margin 24
                    Paragraph "Automate Health Check" -Style Heading1
                    Paragraph "Generated on $(Get-Date -Format G)" -Style Heading2
                    PageBreak
                    TOC -Name "Overview"
                    foreach ($category in ($config.Categories | Where-Object {$_.Enabled} | Sort-Object -Property "SortOrder")) {
                        $thisCategoryResults = $results | Where-Object {$_.Category -eq $category.Name -and $_.ConnectionAlias -eq $c.Alias}
                        if (($thisCategoryResults | Measure-Object).Count -gt 0) {
                            PageBreak                            
                            $categoryResultCount = (($thisCategoryResults | Where-Object {$_.Function -in $countedHealthChecks.Function}).Results | Measure-Object).Count
                            if ($category.ShowCount) {
                                $categoryHeader = "$($category.Name) : $categoryResultCount ($($config.CategoryCountInformationLevel) or above)"
                            } else {
                                $categoryHeader = $category.Name
                            }
                            Section $categoryHeader {
                                foreach ($healthCheck in ($category.HealthChecks | Where-Object {$_.Enabled} | Sort-Object -Property "SortOrder")) {
                                    $thisHealthCheckResult = $thisCategoryResults | Where-Object {$_.Function -eq $healthCheck.Function -and $_.ConnectionAlias -eq $c.Alias}
                                    if (($thisHealthCheckResult | Measure-Object).Count -gt 0) {
                                        LineBreak
                                        $help = Get-Help -Name $thisHealthCheckResult.Function
                                        $healthCheckResultCount = ($thisHealthCheckResult.Results | Measure-Object).Count
                                        if ($healthCheck.ShowCount) {
                                            $healthCheckHeader = "$($help.Synopsis) : $healthCheckResultCount"
                                        } else {
                                            $healthCheckHeader = $help.Synopsis
                                        }
                                        Section $healthCheckHeader {
                                            Paragraph $help.Description.Text
                                            if ($healthCheckResultCount -gt 0) {
                                                switch ($thisHealthCheckResult.Results[0].GetType().FullName) {
                                                    "AMHealthCheckItem" {
                                                        $thisHealthCheckResult.Results | Table -Columns "Name","Value"
                                                    }
                                                    "AMConstructHealthCheckItem" {
                                                        $thisHealthCheckResult.Results | Table -Columns "Name","Path","ID","Hint"
                                                    }
                                                }
                                            }
                                        } -Style "$($healthCheck.Importance)HealthCheckHeader"
                                    } else {
                                        Write-Warning "Could not find health check $($healthCheck.Function) in category $($category.Name) when formatting document!"
                                    }
                                }
                            } -Style "Heading2"
                        } else {
                            Write-Warning "Could not find category $($category.Name) when formatting document!"
                        }
                    }
                } | Export-Document -Format $OutputFormat -Path $OutputPath
            } else {
                Write-Error "Folder $OutputPath does not exist!"
            }
        }
    }
    return $results
}