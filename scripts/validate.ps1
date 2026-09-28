. "$PSScriptRoot/common.ps1"

$parseErrors = $null
$null = [System.Management.Automation.Language.Parser]::ParseFile(
    (Join-Path $PSScriptRoot "common.ps1"),
    [ref]$null,
    [ref]$parseErrors
)
if ($parseErrors.Count -ne 0) {
    throw "PowerShell syntax validation failed for common.ps1"
}

$parseErrors = $null
$null = [System.Management.Automation.Language.Parser]::ParseFile(
    (Join-Path $PSScriptRoot "validate.ps1"),
    [ref]$null,
    [ref]$parseErrors
)
if ($parseErrors.Count -ne 0) {
    throw "PowerShell syntax validation failed for validate.ps1"
}

Invoke-RoModularCMake -Arguments @("--list-presets=all")
Invoke-RoModularCMake -Arguments @("--preset", "romodular_selftest", "--fresh")
Invoke-RoModularCMake -Arguments @("--build", "--preset", "romodular_selftest")
Invoke-RoModularCMake -Arguments @("--build", "build/selftest", "--target", "test")

Write-Host "RoModularBuild validation passed."
