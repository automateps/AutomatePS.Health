function Get-AMHealthCheckConfiguration {
    <#
        .SYNOPSIS
            Gets the configuration for the health check

        .DESCRIPTION
            Get-AMHealthCheckConfiguration pulls the health check configuration from config.json

        .PARAMETER CustomConfigPath
            The path to a JSON file containing health check configuration settings.  This file can include new, custom health checks, or modifications to built in health checks.
    #>
    [CmdletBinding()]
    param (
        [ValidateScript({Test-Path -Path $_})]
        $CustomConfigPath
    )

    $moduleRoot = (Get-Item -Path $PSCommandPath).Directory.Parent.Parent
    $config = Get-Content -Path "$($moduleRoot.FullName)\Config\config.json" | ConvertFrom-Json
    if ($CustomConfigPath) {
        $customConfig = Get-Content -Path $CustomConfigPath | ConvertFrom-Json
        foreach ($category in $customConfig.Categories) {
            # Add new categories
            if ($config.Categories.Name -notcontains $category.Name) {
                $config.Categories += $category
            } else {
                $defaultCategory = $config.Categories | Where-Object {$_.Name -eq $category.Name}
                # Process Enabled property
                if ($null -ne $category.Enabled) {
                    if ($category.Enabled -is [Boolean]) {
                        $defaultCategory.Enabled = $category.Enabled
                    } else {
                        Write-Warning "Boolean value not specified for Enabled property in category $($category.Name)!"
                    }
                }

                # Process SortOrder property
                if ($null -ne $category.SortOrder) {
                    if ($category.SortOrder -is [int]) {
                        $defaultCategory.SortOrder = $category.SortOrder
                    } else {
                        Write-Warning "Integer value not specified for SortOrder property in category $($category.Name)!"
                    }
                }

                # Process HealthChecks
                foreach ($healthCheck in $category.HealthChecks) {
                    if ($defaultCategory.HealthChecks.Name -notcontains $healthCheck.Name) {
                        $defaultCategory.HealthChecks += $healthCheck
                    } else {
                        $defaultHealthCheck = $defaultCategory.HealthChecks | Where-Object {$_.Name -eq $healthCheck.Name}
                        # Process Description property
                        if ($null -ne $healthCheck.Description) {
                            $defaultHealthCheck.Description = $healthCheck.Description
                        }

                        # Process Function property
                        if ($null -ne $healthCheck.Function) {
                            if (Get-Command -Name $healthCheck.Function -ErrorAction SilentlyContinue) {
                                $defaultHealthCheck.Function = $healthCheck.Function
                            } else {
                                Write-Warning "Unrecognized Function '$($healthCheck.Function)' specified for health check $($healthCheck.Name) in category $($category.Name)!"
                            }
                        }

                        # Process Importance property
                        if ($null -ne $healthCheck.Importance) {
                            if ($healthCheck.Importance -in [AMHealthCheckImportance].GetEnumValues()) {
                                $defaultHealthCheck.Importance = $healthCheck.Importance
                            } else {
                                Write-Warning "Unrecognized Importance '$($healthCheck.Importance)' specified for health check $($healthCheck.Name) in category $($category.Name)!"
                            }
                        }

                        # Process ShowCount property
                        if ($null -ne $healthCheck.ShowCount) {
                            if ($healthCheck.ShowCount -is [Boolean]) {
                                $defaultHealthCheck.ShowCount = $healthCheck.ShowCount
                            } else {
                                Write-Warning "Boolean value not specified for ShowCount property in health check $($healthCheck.Name) in category $($category.Name)!"
                            }
                        }
        
                        # Process Enabled property
                        if ($null -ne $healthCheck.Enabled) {
                            if ($healthCheck.Enabled -is [Boolean]) {
                                $defaultHealthCheck.Enabled = $healthCheck.Enabled
                            } else {
                                Write-Warning "Boolean value not specified for Enabled property in health check $($healthCheck.Name) in category $($category.Name)!"
                            }
                        }
        
                        # Process SortOrder property
                        if ($null -ne $healthCheck.SortOrder) {
                            if ($healthCheck.SortOrder -is [int]) {
                                $defaultHealthCheck.SortOrder = $healthCheck.SortOrder
                            } else {
                                Write-Warning "Integer value not specified for SortOrder property in health check $($healthCheck.Name) in category $($category.Name)!"
                            }
                        }
                    }
                }
            }
        }
    }
    return $config
}