# Embedded board and transport contract — 0.6.1

RoModularBuild owns reusable MCU startup, linker templates, bounded runtime,
artifact conversion and generic programmer operations. It has no dependency
on a consumer library, its targets, test cases, report magic or success rules.
Consumers retain application firmware, SDK choices, public presets, feature
options, test manifests, result decoding, CI matrices, artifact policy and
actual hardware evidence. The dependency remains one-way.

## AVR (ATmega328P / ATmega2560)

Use the `avr-gcc/atmega328p.cmake` (AVR5) or `avr-gcc/atmega2560.cmake`
(AVR6) toolchain profile. avr-libc supplies the startup and linker script
selected by `-mmcu`; these are not copied into this repository.

After creating an executable, include `cmake/boards/AVR.cmake` and call
`romodular_configure_avr(MyFirmware)`. It adds the ELF suffix, map file,
Intel HEX conversion (excluding EEPROM), and size output. Consumers select
their clock (`F_CPU`), libraries, allocation policy and application entry point.
The optional `MALLOC_NEW` argument supplies bare AVR scalar/array new/delete
using malloc/free. Use it only without another C++ runtime or Arduino core
that defines those operators; it relies on the toolchain's `-fcheck-new` and
does not add exception or standard-library support.

`scripts/simavr.sh` accepts `--mcu`, `--file`, `--log`, optional `--tool`,
`--frequency` (16000000 Hz), and `--timeout` (60 seconds, maximum 3600).
PowerShell uses `-Mcu`, `-File`, `-Log`, `-Tool`, `-Frequency`, `-Timeout`.
The process must exit successfully before the timeout. Output is captured,
but no application verdict is interpreted. A timeout remains an error even
when the output contains a success marker. Bash requires GNU `timeout`;
PowerShell requires an installed compatible simavr executable. On macOS,
install Homebrew `coreutils`; its `gtimeout` command is detected automatically.

`scripts/avrdude.sh` accepts `--device`, `--programmer`, `--port`, `--file`
(Intel HEX), optional `--tool`, `--config`, `--baud` (115200), `--no-erase`,
and `--log`. PowerShell uses the corresponding `-Device`, `-Programmer`,
`-Port`, `-File`, `-Tool`, `-Config`, `-Baud`, `-NoErase`, `-Log` parameters.
It writes flash using avrdude's normal signature checks and automatic write
verification. It never supplies `-F` or `-V`, or writes fuses/lock bits.
`--no-erase`/`-NoErase` explicitly selects avrdude `-D` for bootloaders that
perform page erase. The consumer chooses the device, protocol and port;
calling this script performs a real flash and replaces the application.
Logs include a companion argument file. Nonzero tool status fails the helper.

Reference: [avrdude options](https://avrdudes.github.io/avrdude/8.3/avrdude_4.html)
and [simavr CLI](https://github.com/buserror/simavr/blob/master/simavr/sim/run_avr.c).
The independent AVR fixture and fake transports test build/transport behavior;
they do not establish physical board verification.

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
