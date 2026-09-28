param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Preset,

    [string]$Prefix = ""
)

. "$PSScriptRoot/common.ps1"

Assert-RoModularConfigured -Preset $Preset

$buildDirectory = Get-RoModularBuildDirectory -Preset $Preset
if (-not $Prefix) {
    $Prefix = Join-Path $script:RoModularDistRoot $Preset
}
$Prefix = Resolve-RoModularPath -Path $Prefix

$configuration = if ($env:ROMODULAR_INSTALL_CONFIGURATION) {
    $env:ROMODULAR_INSTALL_CONFIGURATION
}
else {
    "Release"
}
$arguments = @(
    "--install", $buildDirectory,
    "--prefix", $Prefix,
    "--config", $configuration
)

Invoke-RoModularCMake -Arguments $arguments
