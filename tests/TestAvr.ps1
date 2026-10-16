#requires -Version 7.0
$ErrorActionPreference = 'Stop'
$Root = Split-Path $PSScriptRoot -Parent
$Temp = Join-Path ([IO.Path]::GetTempPath()) ('romodular-avr-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $Temp | Out-Null
try {
    $File = Join-Path $Temp 'firmware with spaces.hex'
    ':00000001FF' | Set-Content $File
    $Fixture = Join-Path $Temp 'tool.ps1'
    @'
$args | Set-Content $env:AVR_TEST_ARGS
Write-Output 'tool output'
if ($env:AVR_TEST_SLEEP -eq '1') { Start-Sleep 10 }
exit ([int]$env:AVR_TEST_STATUS)
'@ | Set-Content $Fixture
    # avrdude uses the call operator, so a PS fixture exercises its native status handling.
    $env:AVR_TEST_ARGS = Join-Path $Temp 'arguments'
    $env:AVR_TEST_STATUS = '0'
    & "$Root/scripts/avrdude.ps1" -Tool $Fixture -Device atmega2560 -Programmer wiring -Port COM3 -File $File -NoErase -Log "$Temp/flash.log"
    $Arguments = Get-Content $env:AVR_TEST_ARGS
    if ($Arguments -notcontains '-D' -or $Arguments -notcontains "flash:w:${File}:i" -or $Arguments -contains '-V' -or $Arguments -contains '-F') { throw 'Unsafe or split flash arguments' }
    $env:AVR_TEST_STATUS = '7'
    $Rejected = $false
    try { & "$Root/scripts/avrdude.ps1" -Tool $Fixture -Device atmega2560 -Programmer wiring -Port COM3 -File $File -Log "$Temp/flash.log" } catch { $Rejected = $true }
    if (-not $Rejected) { throw 'Flash failure was ignored' }
    if ($IsWindows) {
        $Compiler = Join-Path $env:WINDIR 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
        $Source = Join-Path $Temp 'tool.cs'
        @'
using System;
using System.IO;
public class Tool {
    public static void Main(string[] args) {
        File.WriteAllLines(Environment.GetEnvironmentVariable("AVR_TEST_ARGS"), args);
        Console.WriteLine("tool output");
        if (Environment.GetEnvironmentVariable("AVR_TEST_SLEEP") == "1") System.Threading.Thread.Sleep(10000);
        Environment.Exit(int.Parse(Environment.GetEnvironmentVariable("AVR_TEST_STATUS")));
    }
}
'@ | Set-Content $Source
        $Executable = Join-Path $Temp 'tool.exe'
        & $Compiler /nologo /out:$Executable $Source
        if ($LASTEXITCODE -ne 0) { throw 'Cannot build process fixture' }
        foreach ($Scenario in 'success', 'failure', 'timeout') {
            $env:AVR_TEST_STATUS = if ($Scenario -eq 'failure') { '7' } else { '0' }
            $env:AVR_TEST_SLEEP = if ($Scenario -eq 'timeout') { '1' } else { '0' }
            $Rejected = $false
            try { & "$Root/scripts/simavr.ps1" -Tool $Executable -Mcu atmega2560 -File $File -Log "$Temp/sim.log" -Timeout 1 } catch { $Rejected = $true }
            if ($Rejected -ne ($Scenario -ne 'success')) { throw "Invalid simulator result: $Scenario" }
        }
        if ((Get-Content $env:AVR_TEST_ARGS) -notcontains $File) { throw 'Split simulator file argument' }
    }
    Write-Host 'AVR PowerShell transport contract passed'
} finally {
    if ([IO.Path]::GetFullPath($Temp).StartsWith([IO.Path]::GetTempPath())) { Remove-Item -LiteralPath $Temp -Recurse -Force }
    Remove-Item Env:AVR_TEST_ARGS, Env:AVR_TEST_STATUS, Env:AVR_TEST_SLEEP -ErrorAction SilentlyContinue
}
$global:LASTEXITCODE = 0
