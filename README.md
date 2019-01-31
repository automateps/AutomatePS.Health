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
Invoke-AMHealthCheck -OutputPath "C:\temp" -OutputFormat Html,Word -Verbose
```

To execute the health check against a single server:
```PowerShell
Invoke-AMHealthCheck -OutputPath "C:\temp" -OutputFormat Html,Word -Connection dev -Verbose
```

----------
Enabling and Disabling Health Checks
-------------
To disable a health check, open config.json, locate the desired health check and set "Enabled" to "false".  Set back to "true" to re-enable.

----------
Adding Custom Health Checks to the Module
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