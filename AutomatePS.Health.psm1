# Load module functions
Get-ChildItem -Path "$PSScriptRoot\Functions\Public\*.ps1" | ForEach-Object {
    . $_.FullName
    Export-ModuleMember -Function $_.BaseName
}
# Load supporting functions
<#Get-ChildItem -Path "$PSScriptRoot\Functions\Private\*.ps1" | ForEach-Object {
    . $_.FullName
}#>
# Load plugin functions
Get-ChildItem -Path "$PSScriptRoot\Functions\HealthCheck\" -Filter "*.ps1" -Recurse | ForEach-Object {
    . $_.FullName
    Export-ModuleMember -Function $_.BaseName
}