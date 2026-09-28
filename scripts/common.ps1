$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$script:RoModularRoot = Split-Path -Parent $PSScriptRoot
$script:RoModularProjectRoot = if ($env:ROMODULAR_PROJECT_ROOT) {
    [System.IO.Path]::GetFullPath($env:ROMODULAR_PROJECT_ROOT)
}
else {
    $script:RoModularRoot
}
$script:RoModularBuildRoot = if ($env:ROMODULAR_BUILD_ROOT) {
    [System.IO.Path]::GetFullPath($env:ROMODULAR_BUILD_ROOT)
}
else {
    Join-Path $script:RoModularProjectRoot "build"
}
$script:RoModularDistRoot = if ($env:ROMODULAR_DIST_ROOT) {
    [System.IO.Path]::GetFullPath($env:ROMODULAR_DIST_ROOT)
}
else {
    Join-Path $script:RoModularProjectRoot "dist"
}
$script:RoModularProjectLabel = if ($env:ROMODULAR_PROJECT_LABEL) {
    $env:ROMODULAR_PROJECT_LABEL
}
else {
    "project"
}
$script:RoModularConfigureCommand = if ($env:ROMODULAR_CONFIGURE_COMMAND) {
    $env:ROMODULAR_CONFIGURE_COMMAND
}
else {
    "scripts/configure.ps1"
}

function Invoke-RoModularCMake {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)

    & cmake @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "cmake failed with exit code $LASTEXITCODE"
    }
}

function Invoke-RoModularCTest {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)

    & ctest @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "ctest failed with exit code $LASTEXITCODE"
    }
}

function Get-RoModularBuildDirectory {
    param([Parameter(Mandatory = $true)][string]$Preset)
    Assert-RoModularPreset -Preset $Preset
    return Join-Path $script:RoModularBuildRoot $Preset
}

function Assert-RoModularPreset {
    param([Parameter(Mandatory = $true)][string]$Preset)

    if ($Preset -notmatch "^[A-Za-z0-9][A-Za-z0-9_.-]*$" -or $Preset.Contains("..")) {
        throw "Invalid preset name: $Preset"
    }
}

function Get-RoModularConfiguration {
    param(
        [Parameter(Mandatory = $true)][string]$Preset,
        [string]$Configuration = "",
        [string]$DefaultConfiguration = "Debug"
    )

    if ($Configuration) {
        return $Configuration
    }

    if (
        $env:ROMODULAR_DOCUMENTATION_PRESET -and
        $Preset -eq $env:ROMODULAR_DOCUMENTATION_PRESET
    ) {
        if ($env:ROMODULAR_DOCUMENTATION_CONFIGURATION) {
            return $env:ROMODULAR_DOCUMENTATION_CONFIGURATION
        }
        return "Release"
    }

    if ($env:ROMODULAR_DEFAULT_CONFIGURATION) {
        return $env:ROMODULAR_DEFAULT_CONFIGURATION
    }
    return $DefaultConfiguration
}

function Assert-RoModularConfiguration {
    param([Parameter(Mandatory = $true)][string]$Configuration)

    if ($Configuration -notin @("Debug", "Release")) {
        throw "Unsupported configuration '$Configuration'; expected Debug or Release"
    }
}

function Assert-RoModularConfigured {
    param([Parameter(Mandatory = $true)][string]$Preset)

    $buildDirectory = Get-RoModularBuildDirectory -Preset $Preset
    $cache = Join-Path $buildDirectory "CMakeCache.txt"
    if (-not (Test-Path -LiteralPath $cache -PathType Leaf)) {
        throw "Preset '$Preset' is not configured; run $script:RoModularConfigureCommand $Preset first"
    }
}

function Resolve-RoModularPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath(
        (Join-Path $script:RoModularProjectRoot $Path)
    )
}

function Assert-RoModularDistChild {
    param([Parameter(Mandatory = $true)][string]$Path)

    $distRoot = [System.IO.Path]::GetFullPath($script:RoModularDistRoot).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    $candidate = [System.IO.Path]::GetFullPath($Path)
    $prefix = $distRoot + [System.IO.Path]::DirectorySeparatorChar

    $comparison = if ([System.IO.Path]::DirectorySeparatorChar -eq "\") {
        [System.StringComparison]::OrdinalIgnoreCase
    }
    else {
        [System.StringComparison]::Ordinal
    }

    if (-not $candidate.StartsWith($prefix, $comparison)) {
        throw "Refusing to remove export path outside ${distRoot}: $candidate"
    }
}

if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    throw "Required command not found: cmake"
}

Set-Location $script:RoModularProjectRoot
