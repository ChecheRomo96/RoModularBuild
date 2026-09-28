param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Preset,

    [string]$Configuration = "",
    [int]$Parallel = 0,
    [string]$Filter = "",
    [string]$JUnit = "",
    [switch]$Fresh,
    [switch]$AllowNoTests
)

. "$PSScriptRoot/common.ps1"

$configurationName = Get-RoModularConfiguration `
    -Preset $Preset `
    -Configuration $Configuration `
    -DefaultConfiguration "Debug"
Assert-RoModularConfiguration -Configuration $configurationName

$configureParameters = @{
    Preset = $Preset
}
if ($env:ROMODULAR_TESTING_CACHE_ARGUMENT) {
    $configureParameters.CMakeArguments = @(
        $env:ROMODULAR_TESTING_CACHE_ARGUMENT
    )
}
if ($Fresh) {
    $configureParameters.Fresh = $true
}
& "$PSScriptRoot/configure.ps1" @configureParameters

$buildDirectory = Get-RoModularBuildDirectory -Preset $Preset
$buildArguments = @("--build", $buildDirectory, "--config", $configurationName)
if ($Parallel -gt 0) {
    $buildArguments += @("--parallel", $Parallel.ToString())
}
Invoke-RoModularCMake -Arguments $buildArguments

$arguments = @("--test-dir", $buildDirectory, "--output-on-failure")
if (-not $AllowNoTests) {
    $arguments += "--no-tests=error"
}
$arguments += @("--build-config", $configurationName)
if ($Parallel -gt 0) {
    $arguments += @("--parallel", $Parallel.ToString())
}
if ($Filter) {
    $arguments += @("--tests-regex", $Filter)
}
if ($JUnit) {
    $junitPath = Resolve-RoModularPath -Path $JUnit
    $junitDirectory = Split-Path -Parent $junitPath
    New-Item -ItemType Directory -Path $junitDirectory -Force | Out-Null
    $arguments += @("--output-junit", $junitPath)
}

Invoke-RoModularCTest -Arguments $arguments
