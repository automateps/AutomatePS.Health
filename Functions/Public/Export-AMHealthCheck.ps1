function Export-AMHealthCheck {
    <#
        .SYNOPSIS
            Exports a health check against Automate Enterprise to a file.

        .DESCRIPTION
            Export-AMHealthCheck exports Automate Enterprise health check results to a file.

        .PARAMETER HealthCheckResult
            The health check results to export

        .PARAMETER OutputPath
            The location to save the health check results

        .PARAMETER OutputFormat
            The format to save the health check results in: HTML, Word, Text, XML
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $HealthCheckResult,
        
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_})]
        $OutputPath,

        [ValidateSet("HTML","Word","Text","XML")]
        $OutputFormat = "HTML"
    )

    foreach ($connection in ($HealthCheckResult | Group-Object -Property ConnectionAlias).Name) {
        Document "Automate_Health_Check_$($connection.Replace(":","_"))_$(Get-Date -Format "yyyyMMddhhmmss")" {
            Style -Name "InformationHealthCheckHeader" -Size 12 -Color Gray
            Style -Name "WarningHealthCheckHeader" -Size 12 -Color Orange
            Style -Name "ErrorHealthCheckHeader" -Size 12 -Color Red
            DocumentOption -Margin 24
            Paragraph "Automate Health Check" -Style Heading1
            Paragraph "Generated on $(Get-Date -Format G)" -Style Heading2
            PageBreak
            TOC -Name "Overview"

            foreach ($category in ($HealthCheckResult | Where-Object {$_.ConnectionAlias -eq $connection} | Group-Object Category).Name) {
                $thisCategoryResults = $HealthCheckResult | Where-Object {$_.Category -eq $category -and $_.ConnectionAlias -eq $connection}
                if (($thisCategoryResults | Measure-Object).Count -gt 0) {
                    PageBreak
                    Section $category {
                        foreach ($healthCheck in ($HealthCheckResult | Where-Object {$_.Category -eq $category -and $_.ConnectionAlias -eq $connection})) {
                            $thisHealthCheckResult = $thisCategoryResults | Where-Object {$_.Function -eq $healthCheck.Function -and $_.ConnectionAlias -eq $connection}
                            if (($thisHealthCheckResult | Measure-Object).Count -gt 0) {
                                LineBreak
                                $healthCheckResultCount = ($thisHealthCheckResult.Results | Measure-Object).Count
                                if ($healthCheck.ShowCount) {
                                    $healthCheckHeader = "$($healthCheck.Name) : $healthCheckResultCount"
                                } else {
                                    $healthCheckHeader = $healthCheck.Name
                                }
                                Section $healthCheckHeader {
                                    Paragraph $healthCheck.Description
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
    }
}