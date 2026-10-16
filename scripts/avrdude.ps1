#requires -Version 7.0
[CmdletBinding()]
param(
    [string]$Tool = 'avrdude',
    [Parameter(Mandatory)][string]$Device,
    [Parameter(Mandatory)][string]$Programmer,
    [Parameter(Mandatory)][string]$Port,
    [Parameter(Mandatory)][string]$File,
    [string]$Config = '',
    [ValidateRange(1, 4000000)][int]$Baud = 115200,
    [switch]$NoErase,
    [string]$Log = ''
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$File = [IO.Path]::GetFullPath($File)
if (-not (Test-Path -LiteralPath $File -PathType Leaf)) { throw 'Firmware file not found' }
if ([IO.Path]::GetExtension($File) -ne '.hex') { throw 'Firmware must be Intel HEX (.hex)' }
$Arguments = @('-p', $Device, '-c', $Programmer, '-P', $Port, '-b', "$Baud")
if ($Config) {
    if (-not (Test-Path -LiteralPath $Config -PathType Leaf)) { throw 'Configuration file not found' }
    $Arguments += @('-C', $Config)
}
if ($NoErase) { $Arguments += '-D' }
# Verification and device signature checks remain enabled.
$Arguments += @('-U', "flash:w:${File}:i")
if ($Log) {
    $Log = [IO.Path]::GetFullPath($Log)
    New-Item -ItemType Directory -Path (Split-Path $Log -Parent) -Force | Out-Null
    $Arguments | ConvertTo-Json | Set-Content -LiteralPath "$Log.command.json"
    & $Tool @Arguments 2>&1 | Tee-Object -FilePath $Log | Out-Host
} else { & $Tool @Arguments | Out-Host }
if ($LASTEXITCODE -ne 0) { throw "avrdude flash failed ($LASTEXITCODE)" }
