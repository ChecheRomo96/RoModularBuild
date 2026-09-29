$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Get-RoModularCiBoolean {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Value = "false"
    )

    if ($Value -notin @("true", "false")) {
        throw "$Name must be true or false, got '$Value'"
    }
    return $Value -eq "true"
}

function Assert-RoModularCiPreset {
    if (-not $env:ROMODULAR_CI_PRESET) {
        throw "Command '$env:ROMODULAR_CI_COMMAND' requires a preset"
    }
}

$projectDirectory = if ($env:ROMODULAR_CI_PROJECT_DIRECTORY) {
    $env:ROMODULAR_CI_PROJECT_DIRECTORY
}
else {
    "."
}
$scriptDirectory = if ($env:ROMODULAR_CI_SCRIPT_DIRECTORY) {
    $env:ROMODULAR_CI_SCRIPT_DIRECTORY
}
else {
    "scripts"
}

Set-Location -LiteralPath $projectDirectory

$fresh = Get-RoModularCiBoolean `
    -Name "fresh" -Value $env:ROMODULAR_CI_FRESH
$cleanFirst = Get-RoModularCiBoolean `
    -Name "clean-first" -Value $env:ROMODULAR_CI_CLEAN_FIRST
$examplesOn = Get-RoModularCiBoolean `
    -Name "examples-on" -Value $env:ROMODULAR_CI_EXAMPLES_ON
$allowNoTests = Get-RoModularCiBoolean `
    -Name "allow-no-tests" -Value $env:ROMODULAR_CI_ALLOW_NO_TESTS
$dist = Get-RoModularCiBoolean `
    -Name "dist" -Value $env:ROMODULAR_CI_DIST
$all = Get-RoModularCiBoolean `
    -Name "all" -Value $env:ROMODULAR_CI_ALL

$parallel = 0
if (-not [int]::TryParse($env:ROMODULAR_CI_PARALLEL, [ref]$parallel) -or
    $parallel -lt 0) {
    throw "parallel must be a non-negative integer"
}

$script = Join-Path $scriptDirectory "$env:ROMODULAR_CI_COMMAND.ps1"
if (-not (Test-Path -LiteralPath $script -PathType Leaf)) {
    throw "Consumer workflow script is missing: $script"
}

switch ($env:ROMODULAR_CI_COMMAND) {
    "configure" {
        Assert-RoModularCiPreset
        $parameters = @{ Preset = $env:ROMODULAR_CI_PRESET }
        if ($fresh) { $parameters.Fresh = $true }
    }
    "build" {
        Assert-RoModularCiPreset
        $parameters = @{ Preset = $env:ROMODULAR_CI_PRESET }
        if ($env:ROMODULAR_CI_CONFIGURATION) {
            $parameters.Configuration = $env:ROMODULAR_CI_CONFIGURATION
        }
        if ($env:ROMODULAR_CI_TARGET) {
            $parameters.Target = $env:ROMODULAR_CI_TARGET
        }
        if ($parallel -gt 0) { $parameters.Parallel = $parallel }
        if ($cleanFirst) { $parameters.CleanFirst = $true }
        if ($fresh) { $parameters.Fresh = $true }
        if ($examplesOn) { $parameters.ExamplesOn = $true }
    }
    "test" {
        Assert-RoModularCiPreset
        $parameters = @{ Preset = $env:ROMODULAR_CI_PRESET }
        if ($env:ROMODULAR_CI_CONFIGURATION) {
            $parameters.Configuration = $env:ROMODULAR_CI_CONFIGURATION
        }
        if ($parallel -gt 0) { $parameters.Parallel = $parallel }
        if ($env:ROMODULAR_CI_FILTER) {
            $parameters.Filter = $env:ROMODULAR_CI_FILTER
        }
        if ($env:ROMODULAR_CI_JUNIT) {
            $parameters.JUnit = $env:ROMODULAR_CI_JUNIT
        }
        if ($fresh) { $parameters.Fresh = $true }
        if ($allowNoTests) { $parameters.AllowNoTests = $true }
    }
    "install" {
        Assert-RoModularCiPreset
        $parameters = @{ Preset = $env:ROMODULAR_CI_PRESET }
        if ($env:ROMODULAR_CI_PREFIX) {
            $parameters.Prefix = $env:ROMODULAR_CI_PREFIX
        }
    }
    "clean" {
        $parameters = @{}
        if ($all) {
            if ($env:ROMODULAR_CI_PRESET) {
                throw "Clean cannot combine a preset with all=true"
            }
            $parameters.All = $true
        }
        else {
            Assert-RoModularCiPreset
            $parameters.Preset = $env:ROMODULAR_CI_PRESET
        }
        if ($dist) { $parameters.Dist = $true }
    }
    default {
        throw "Unsupported command '$env:ROMODULAR_CI_COMMAND'; expected configure, build, test, install, or clean"
    }
}

& $script @parameters
