#requires -Version 7.0
$ErrorActionPreference = "Stop"
$Root = Split-Path $PSScriptRoot -Parent
$Fixture = Join-Path ([IO.Path]::GetTempPath()) ("romodular-stlink-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $Fixture | Out-Null
$Programmer = Join-Path $Fixture "fake programmer.ps1"
$ArgumentsFile = Join-Path $Fixture "arguments.json"
$Firmware = Join-Path $Fixture "input firmware.elf"
$ReadFile = Join-Path $Fixture "read output.bin"
Set-Content $Firmware "synthetic firmware"
@'
$args | ConvertTo-Json | Set-Content $env:ROMODULAR_STLINK_TEST_ARGS
if ($env:ROMODULAR_STLINK_TEST_FAIL -eq '1') { $global:LASTEXITCODE=7; return }
$index = [array]::IndexOf($args, '-u')
if ($index -ge 0) {
    $count = [int]$args[$index+2]
    if ($env:ROMODULAR_STLINK_TEST_SHORT -eq '1') { $count=1 }
    [IO.File]::WriteAllBytes($args[$index+3], [byte[]]::new($count))
}
$global:LASTEXITCODE=0
'@ | Set-Content $Programmer
$Previous = @{}
foreach ($Name in 'ROMODULAR_STLINK_TEST_ARGS','ROMODULAR_STLINK_TEST_FAIL','ROMODULAR_STLINK_TEST_SHORT') {
    $Previous[$Name]=[Environment]::GetEnvironmentVariable($Name)
}
try {
    $env:ROMODULAR_STLINK_TEST_ARGS=$ArgumentsFile
    $env:ROMODULAR_STLINK_TEST_FAIL='0'; $env:ROMODULAR_STLINK_TEST_SHORT='0'
    & "$Root/scripts/stlink.ps1" -Action Flash -Programmer $Programmer -File $Firmware -ProbeSerial 'probe 3'
    $Captured=Get-Content $ArgumentsFile -Raw | ConvertFrom-Json
    if ($Captured -notcontains $Firmware -or $Captured -notcontains 'sn=probe 3' -or
        $Captured -notcontains '-v' -or $Captured -notcontains '-rst') { throw 'Invalid flash arguments' }
    & "$Root/scripts/stlink.ps1" -Action Read -Programmer $Programmer -File $ReadFile -Address 0x20000000 -Size 8
    $Captured=Get-Content $ArgumentsFile -Raw | ConvertFrom-Json
    if ($Captured -notcontains 'mode=HOTPLUG' -or (Get-Item $ReadFile).Length -ne 8) { throw 'Invalid read arguments' }
    foreach ($Scenario in 'exit-code','short-read','bad-address','bad-size','binary-without-address') {
        $env:ROMODULAR_STLINK_TEST_FAIL=if($Scenario -eq 'exit-code') {'1'} else {'0'}
        $env:ROMODULAR_STLINK_TEST_SHORT=if($Scenario -eq 'short-read') {'1'} else {'0'}
        $Address=if($Scenario -eq 'bad-address') {'invalid'} else {'0x20000000'}
        $Size=if($Scenario -eq 'bad-size') {0} else {8}
        $Rejected=$false
        try {
            if($Scenario -eq 'binary-without-address') {
                $Binary=Join-Path $Fixture 'input.bin'; Set-Content $Binary 'binary'
                & "$Root/scripts/stlink.ps1" -Action Flash -Programmer $Programmer -File $Binary
            }
            else { & "$Root/scripts/stlink.ps1" -Action Read -Programmer $Programmer -File $ReadFile -Address $Address -Size $Size }
        }
        catch { $Rejected=$true }
        if(-not $Rejected) { throw "Accepted invalid transport scenario: $Scenario" }
    }
    Write-Host 'ST-LINK PowerShell contract passed (synthetic transport only)'
}
finally { foreach($Name in $Previous.Keys) { [Environment]::SetEnvironmentVariable($Name,$Previous[$Name]) } }
$global:LASTEXITCODE=0
