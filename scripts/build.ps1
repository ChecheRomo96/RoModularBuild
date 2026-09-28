param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Preset,

    [string]$Configuration = "",
    [string]$Target = "",
    [int]$Parallel = 0,
    [switch]$CleanFirst,
    [switch]$Fresh,
    [Alias("examples-on")]
    [switch]$ExamplesOn
)

. "$PSScriptRoot/common.ps1"

$configureParameters = @{
    Preset = $Preset
}
if ($Fresh) {
    $configureParameters.Fresh = $true
}
if ($ExamplesOn) {
    if (-not $env:ROMODULAR_EXAMPLES_CACHE_ARGUMENT) {
        throw "$script:RoModularProjectLabel does not define an examples cache argument"
    }
    $configureParameters.CMakeArguments = @(
        $env:ROMODULAR_EXAMPLES_CACHE_ARGUMENT
    )
}
& "$PSScriptRoot/configure.ps1" @configureParameters

$buildDirectory = Get-RoModularBuildDirectory -Preset $Preset
$configurationName = Get-RoModularConfiguration `
    -Preset $Preset `
    -Configuration $Configuration `
    -DefaultConfiguration "Debug"
Assert-RoModularConfiguration -Configuration $configurationName
$arguments = @("--build", $buildDirectory, "--config", $configurationName)

if ($Target) {
    $arguments += @("--target", $Target)
}
if ($Parallel -gt 0) {
    $arguments += @("--parallel", $Parallel.ToString())
}
if ($CleanFirst) {
    $arguments += "--clean-first"
}

Invoke-RoModularCMake -Arguments $arguments
