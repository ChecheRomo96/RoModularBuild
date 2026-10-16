# Embedded board and transport contract — 0.5.0

RoModularBuild owns reusable MCU startup, linker templates, bounded runtime,
artifact conversion and generic programmer operations. It has no dependency
on a consumer library, its targets, test cases, report magic or success rules.
Consumers retain application firmware, SDK choices, public presets, feature
options, test manifests, result decoding, CI matrices, artifact policy and
actual hardware evidence. The dependency remains one-way.

## STM32G0B1CBT6

Configure with the shared Cortex-M0+ GNU Arm toolchain. Enable CXX and ASM,
create an executable containing the consumer's `main`, then apply:

```cmake
include("${build_support}/cmake/boards/STM32G0B1CBT6.cmake")
add_executable(MyFirmware main.cpp)
romodular_configure_stm32g0b1cbt6(MyFirmware)
```

The module adds startup and runtime sources, an ELF suffix, linker options,
map/HEX/BIN/size artifacts, and a generated linker script from its shared
template. It requires GNU Arm Cortex-M0+, newlib-nano and an existing
executable; it does not choose any consumer library or test configuration.

The board uses 128 KiB flash and the normal 128 KiB SRAM region. Configurable
positive, 8-byte-aligned byte counts are `ROMODULAR_STM32_HEAP_BYTES` (16384)
and `ROMODULAR_STM32_STACK_BYTES` (8192). Link-time checks reject overlap.
Startup copies data, clears BSS, runs C++ initializers and calls `main` with
interrupts disabled at the reset clock configuration. No HAL/Arduino/RTOS or
peripheral setup is included. Application clock and interrupt setup is owned
by the caller.

The bounded `_sbrk` supports newlib allocation; file I/O is explicitly
unsupported. The weak `extern "C"` hook `romodular_fault_handler()` can be
overridden to record consumer-specific diagnostics, and must not return.
After `main` returns, or by default on a fault, the CPU remains active so a
new SWD connection can read application state. No WFI or semihosting is used.

## ST-LINK transport

PowerShell 7:

```powershell
& "$buildSupport/scripts/stlink.ps1" -Action Flash -Programmer $programmer -File $elf
& "$buildSupport/scripts/stlink.ps1" -Action Read -Programmer $programmer `
    -Address 0x20000000 -Size 128 -File $report
```

POSIX shell:

```sh
sh "$build_support/scripts/stlink.sh" --action flash --programmer "$programmer" --file "$elf"
sh "$build_support/scripts/stlink.sh" --action read --programmer "$programmer" \
  --address 0x20000000 --size 128 --file "$report"
```

Both variants accept frequency (100..4000 kHz, default 1000), probe serial
and an optional log path. Flash writes, verifies and resets. Raw binary input
requires an explicit address. Read uses HOTPLUG, replaces only the requested
output file, rejects stale/partial output and checks the programmer exit code.
The transport never interprets the bytes or reports a product test pass.

`tests/fixtures/stm32-board` is a synthetic independent consumer used to
cross-link this support without product source. Transport tests use fake
programmers and never access hardware. Neither build-only CI nor simulated
transport tests constitute physical execution evidence.
