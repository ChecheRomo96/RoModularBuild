$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($env:ROMODULAR_CI_REQUIRE_NINJA -notin @("true", "false")) {
    throw "require-ninja must be true or false, got '$env:ROMODULAR_CI_REQUIRE_NINJA'"
}
if (-not $env:ROMODULAR_CI_COMPILER) {
    throw "compiler is required"
}

cmake --version
if ($LASTEXITCODE -ne 0) { throw "cmake --version failed" }

if ($env:ROMODULAR_CI_REQUIRE_NINJA -eq "true") {
    ninja --version
    if ($LASTEXITCODE -ne 0) { throw "ninja --version failed" }
}

switch ($env:ROMODULAR_CI_COMPILER) {
    "msvc" {
        $vswhere = Join-Path `
            ${env:ProgramFiles(x86)} `
            "Microsoft Visual Studio/Installer/vswhere.exe"
        if (-not (Test-Path -LiteralPath $vswhere -PathType Leaf)) {
            throw "vswhere was not found: $vswhere"
        }
        & $vswhere -latest -products * `
            -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
            -property installationVersion
    }
    "clang" {
        clang++ --version
    }
    default {
        & $env:ROMODULAR_CI_COMPILER --version
    }
}
if ($LASTEXITCODE -ne 0) {
    throw "Compiler report failed for '$env:ROMODULAR_CI_COMPILER'"
}

Write-Host ([System.Environment]::OSVersion.VersionString)
