param(
    [Parameter(Position = 0)]
    [string]$Preset = "",

    [switch]$All,
    [switch]$Dist
)

. "$PSScriptRoot/common.ps1"

if ($All -and $Preset) {
    throw "Specify either a preset or -All, not both"
}
if (-not $All -and -not $Preset) {
    throw "A preset or -All is required"
}

if ($All) {
    if (Test-Path -LiteralPath $script:RoModularBuildRoot) {
        Remove-Item -LiteralPath $script:RoModularBuildRoot -Recurse -Force
    }
    if ($Dist -and (Test-Path -LiteralPath $script:RoModularDistRoot)) {
        Remove-Item -LiteralPath $script:RoModularDistRoot -Recurse -Force
    }
}
else {
    $buildDirectory = Get-RoModularBuildDirectory -Preset $Preset
    $distDirectory = Join-Path $script:RoModularDistRoot $Preset
    if (Test-Path -LiteralPath $buildDirectory) {
        Remove-Item -LiteralPath $buildDirectory -Recurse -Force
    }
    if ($Dist -and (Test-Path -LiteralPath $distDirectory)) {
        Remove-Item -LiteralPath $distDirectory -Recurse -Force
    }
}
