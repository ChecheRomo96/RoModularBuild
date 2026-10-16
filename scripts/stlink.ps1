#requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet("Flash", "Read")][string]$Action,
    [Parameter(Mandatory)][string]$Programmer,
    [Parameter(Mandatory)][string]$File,
    [string]$Address = "",
    [long]$Size = 0,
    [ValidateRange(100, 4000)][int]$Frequency = 1000,
    [string]$ProbeSerial = "",
    [string]$Log = ""
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
if ($Address -and $Address -notmatch '^0x[0-9a-fA-F]{1,8}$') { throw "Address must be a 32-bit hexadecimal address" }
$File = [IO.Path]::GetFullPath($File)
$Arguments = @("-c", "port=SWD", "freq=$Frequency")
if ($ProbeSerial) { $Arguments += "sn=$ProbeSerial" }
if ($Action -eq "Flash") {
    if (-not (Test-Path -LiteralPath $File -PathType Leaf)) { throw "Firmware file not found: $File" }
    if ([IO.Path]::GetExtension($File) -eq ".bin" -and -not $Address) { throw "Binary flash requires an explicit -Address" }
    $Arguments += @("-w", $File)
    if ($Address) { $Arguments += $Address }
    $Arguments += @("-v", "-rst")
}
else {
    if (-not $Address -or $Size -le 0 -or $Size -gt 4294967295) { throw "Read requires -Address and a positive 32-bit -Size" }
    if (Test-Path -LiteralPath $File -PathType Container) { throw "Read destination is a directory" }
    New-Item -ItemType Directory -Path (Split-Path $File -Parent) -Force | Out-Null
    if (Test-Path -LiteralPath $File) { Remove-Item -LiteralPath $File }
    $Arguments += @("mode=HOTPLUG", "-u", $Address, "$Size", $File)
}
if ($Log) {
    $Log = [IO.Path]::GetFullPath($Log)
    New-Item -ItemType Directory -Path (Split-Path $Log -Parent) -Force | Out-Null
    $Arguments | ConvertTo-Json | Set-Content -LiteralPath "$Log.command.json"
    & $Programmer @Arguments 2>&1 | Tee-Object -FilePath $Log | Out-Host
}
else { & $Programmer @Arguments | Out-Host }
if ($LASTEXITCODE -ne 0) { throw "ST-LINK $Action failed ($LASTEXITCODE)" }
if ($Action -eq "Read" -and (Get-Item -LiteralPath $File).Length -ne $Size) { throw "ST-LINK returned an incomplete memory read" }
