$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$script:RoModularRoot = Split-Path -Parent $PSScriptRoot

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

if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    throw "Required command not found: cmake"
}

if (-not (Get-Command ctest -ErrorAction SilentlyContinue)) {
    throw "Required command not found: ctest"
}

Set-Location $script:RoModularRoot
