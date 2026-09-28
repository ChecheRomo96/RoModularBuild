. "$PSScriptRoot/common.ps1"

$workflowScripts = @(
    "common.ps1",
    "configure.ps1",
    "build.ps1",
    "test.ps1",
    "install.ps1",
    "clean.ps1",
    "validate.ps1"
)
foreach ($workflowScript in $workflowScripts) {
    $parseErrors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile(
        (Join-Path $PSScriptRoot $workflowScript),
        [ref]$null,
        [ref]$parseErrors
    )
    if ($parseErrors.Count -ne 0) {
        throw "PowerShell syntax validation failed for $workflowScript"
    }
}

Invoke-RoModularCMake -Arguments @("--list-presets=all")

& "$PSScriptRoot/configure.ps1" romodular_selftest -Fresh
$stalePath = Join-Path $script:RoModularBuildRoot `
    "romodular_selftest/stale-before-fresh"
New-Item -ItemType File -Path $stalePath -Force | Out-Null
& "$PSScriptRoot/configure.ps1" romodular_selftest -Fresh
if (Test-Path -LiteralPath $stalePath) {
    throw "-Fresh did not remove the complete preset build tree"
}

& "$PSScriptRoot/build.ps1" romodular_selftest -Configuration Debug
$junitPath = "build/validation/romodular-selftest.xml"
& "$PSScriptRoot/test.ps1" romodular_selftest `
    -Configuration Debug `
    -JUnit $junitPath
if (-not (Test-Path -LiteralPath (Resolve-RoModularPath -Path $junitPath))) {
    throw "Test workflow did not create the requested JUnit report"
}

& "$PSScriptRoot/install.ps1" romodular_selftest
$installedVersion = Join-Path $script:RoModularDistRoot `
    "romodular_selftest/share/RoModularBuild/VERSION"
if (-not (Test-Path -LiteralPath $installedVersion -PathType Leaf)) {
    throw "Install workflow did not create the expected artifact"
}

& "$PSScriptRoot/clean.ps1" romodular_selftest
$selfTestBuild = Join-Path $script:RoModularBuildRoot "romodular_selftest"
$selfTestDist = Join-Path $script:RoModularDistRoot "romodular_selftest"
if (Test-Path -LiteralPath $selfTestBuild) {
    throw "Clean workflow did not remove the preset build tree"
}
if (-not (Test-Path -LiteralPath $selfTestDist -PathType Container)) {
    throw "Build-only clean unexpectedly removed the distribution"
}
& "$PSScriptRoot/clean.ps1" romodular_selftest -Dist
if (Test-Path -LiteralPath $selfTestDist) {
    throw "Distribution clean did not remove the preset export"
}

$emptySuiteFailed = $false
try {
    & "$PSScriptRoot/test.ps1" romodular_no_tests -Fresh
}
catch {
    $emptySuiteFailed = $true
}
if (-not $emptySuiteFailed) {
    throw "Test workflow accepted an empty suite without -AllowNoTests"
}
& "$PSScriptRoot/test.ps1" romodular_no_tests -AllowNoTests
& "$PSScriptRoot/clean.ps1" romodular_no_tests -Dist

Write-Host "RoModularBuild validation passed."
