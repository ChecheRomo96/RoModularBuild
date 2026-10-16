#requires -Version 7.0
[CmdletBinding()]
param(
    [string]$Tool = 'simavr',
    [Parameter(Mandatory)][string]$Mcu,
    [Parameter(Mandatory)][string]$File,
    [ValidateRange(1, 100000000)][int]$Frequency = 16000000,
    [ValidateRange(1, 3600)][int]$Timeout = 60,
    [Parameter(Mandatory)][string]$Log
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$File = [IO.Path]::GetFullPath($File)
if (-not (Test-Path -LiteralPath $File -PathType Leaf)) { throw 'Firmware file not found' }
$Log = [IO.Path]::GetFullPath($Log)
New-Item -ItemType Directory -Path (Split-Path $Log -Parent) -Force | Out-Null
$Info = [Diagnostics.ProcessStartInfo]::new($Tool)
$Info.UseShellExecute = $false
$Info.RedirectStandardOutput = $true
$Info.RedirectStandardError = $true
foreach ($Argument in @('-m', $Mcu, '-f', "$Frequency", $File)) { $Info.ArgumentList.Add($Argument) }
@($Info.ArgumentList) | ConvertTo-Json | Set-Content -LiteralPath "$Log.command.json"
$Process = [Diagnostics.Process]::new()
$Process.StartInfo = $Info
try {
    [void]$Process.Start()
    $Output = $Process.StandardOutput.ReadToEndAsync()
    $Errors = $Process.StandardError.ReadToEndAsync()
    $Finished = $Process.WaitForExit($Timeout * 1000)
    if (-not $Finished) { $Process.Kill($true); $Process.WaitForExit() }
    $Text = $Output.GetAwaiter().GetResult() + $Errors.GetAwaiter().GetResult()
    $Text | Set-Content -LiteralPath $Log
    Write-Host $Text
    if (-not $Finished) { throw "simavr timed out after $Timeout seconds" }
    if ($Process.ExitCode -ne 0) { throw "simavr failed ($($Process.ExitCode))" }
} finally { $Process.Dispose() }
