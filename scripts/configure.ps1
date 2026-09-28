param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Preset,

    [switch]$Fresh,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$CMakeArguments
)

. "$PSScriptRoot/common.ps1"

if ($Fresh) {
    $buildDirectory = Get-RoModularBuildDirectory -Preset $Preset
    if (Test-Path -LiteralPath $buildDirectory) {
        Remove-Item -LiteralPath $buildDirectory -Recurse -Force
    }
}

$arguments = @("--preset", $Preset)
$effectiveCMakeArguments = @(
    $CMakeArguments | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_)
    }
)
if ($effectiveCMakeArguments.Count -gt 0) {
    $arguments += $effectiveCMakeArguments
}

Invoke-RoModularCMake -Arguments $arguments
