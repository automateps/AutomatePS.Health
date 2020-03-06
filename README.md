AutomatePS.Health PowerShell Module
===================

AutomatePS.Health is an extensible module for performing health checks against Help Systems' Automate Enterprise.

----------
Installing the Module
-------------

Install this module from the PowerShell Gallery using:
```PowerShell
Install-Module AutomatePS.Health
```
AutomatePS is a required dependency for AutomatePS.Health, and will install automatically when this module is installed from the PowerShell Gallery.

Additionally, the documents produced by this module were built using PScribo: https://github.com/iainbrighton/PScribo

PScribo should also automatically install when installing from the PowerShell gallery.

----------
Using the Module
-------------
Import the module (currently required, even with PowerShell module auto loading)
```PowerShell
Import-Module AutomatePS.Health
```

Connect to an Automate Enterprise server:
```PowerShell
$myCredential = Get-Credential
Connect-AMServer "AMserver01" -Credential $myCredential -ConnectionAlias dev
```

To execute the health check against all connected servers:
```PowerShell
$health = Invoke-AMHealthCheck
```

To execute the health check against a single server:
```PowerShell
$health = Invoke-AMHealthCheck -Connection dev
```

To export health checks that returned results:
```PowerShell
Export-AMHealthCheck -HealthCheckResult $health -OutputPath "C:\temp" -OutputFormat Html,Word
```

To export all health checks (including those without results):
```PowerShell
Export-AMHealthCheck -HealthCheckResult $health -OutputPath "C:\temp" -OutputFormat Html,Word -IncludeZeroResult
```

----------
Enabling and Disabling Health Checks
-------------
To disable a health check, open config.json, locate the desired health check and set "Enabled" to "false".  Set back to "true" to re-enable.

----------
Adding Custom Health Checks to this Module
-------------

To add a custom health check, create a function:
```PowerShell
function Get-ExampleHealthCheck {
    <#
        .SYNOPSIS
            The synopsis is used for the heading for the health check in the report

        .DESCRIPTION
            The description is placed under the heading in the health check report, describes the purpose of the health check
    #>
    [CmdletBinding()]
    param (
        $Workflows
    )

    foreach ($workflow in $Workflows) {
        if (<# Some condition is true #>) {
            [AMConstructHealthCheckItem]::New($workflow, "Something is wrong with this workflow")
        }
    }
}
```

This function will automatically be fed workflows in the -Workflows parameter for you by Invoke-AMHealthCheck.  Similarly, you can define the following parameters to receive data from Invoke-AMHealthCheck:
```PowerShell
$Workflows
$Tasks
$Conditions
$Processes
$Agents
$AgentGroups
$Users
$UserGroups
$Server
$Execution
$Management
```

Additionally, there are a few "convenience" parameters that can be used:
```PowerShell
$AllAgents  # All agents/agent groups
$AllUsers   # All users/user groups
$Repository # All workflows/tasks/processes/conditions
```

Save the new function under Functions\HealthCheck in the module directory.  The sub-folders in HealthCheck are simply organizational, and have no impact on how the health check operates.  Finally, config.json will need to be modified to reflect the new health check.

----------

Building a Custom Config.json
-------------
If it is preferred not to edit the config.json in this module, a custom config.json can be built using the same structure.  This custom config.json can then be fed into Invoke-AMHealthCheck -CustomConfigPath, and any settings defined for built-in health checks will override those in the config.json included in this module.  This way, minor modifications can be completed easily without replicating the entire default config.json.

In the example below, a custom health check is defined in the Workflows category named "Workflows without variables", the "Disabled Tasks" health check in the "Tasks" category is disabled, and the entire "Processes" category is disabled.  This example depends on the function Get-WorkflowsWithoutVars being loaded in the PowerShell session.
```json
{
    "Categories": [
        {
            "Name": "Workflows",
            "HealthChecks": [
                {
                    "Name": "Workflows without variables",
                    "Description": "Workflows that don't follow the naming standard",
                    "Function": "Get-WorkflowsWithoutVars",
                    "Importance": "Warning",
                    "ShowCount": true,
                    "Enabled": true,
                    "SortOrder": 10
                }
            ]
        },
        {
            "Name": "Tasks",
            "HealthChecks": [
                {
                    "Name": "Disabled Tasks",
                    "Enabled": false
                }
            ]
        },
        {
            "Name": "Processes",
            "Enabled": false
        }
    ]
}
```
