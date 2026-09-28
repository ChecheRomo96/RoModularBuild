# Toolchain contract

RoModularBuild `0.2.1` owns project-independent native and embedded compiler
profiles. Consumers inherit hidden preset bases and keep their public preset
names, project feature options, and package identities local.

## Shared variables

GNU Arm Embedded:

- `ROMODULAR_ARM_TOOLCHAIN_ROOT`
- `ROMODULAR_ARM_TOOLCHAIN_PREFIX`
- `ROMODULAR_ARM_CPU`
- `ROMODULAR_FLOAT_ABI`
- `ROMODULAR_FPU`
- `ROMODULAR_ARM_ADDITIONAL_FLAGS`
- `ROMODULAR_ARM_SYSROOT`

AVR-GCC:

- `ROMODULAR_AVR_TOOLCHAIN_ROOT`
- `ROMODULAR_AVR_TOOLCHAIN_PREFIX`
- `ROMODULAR_AVR_MCU`
- `ROMODULAR_AVR_ARCHITECTURE`
- `ROMODULAR_AVR_ADDITIONAL_FLAGS`

All shared variables are CMake cache entries so a consumer adapter can map
legacy names before including the generic implementation. Consumer-specific
variable names are forbidden in this repository.

## Embedded profiles

| Hidden preset | Processor | Float ABI / MCU |
| --- | --- | --- |
| `romodular_arm_none_eabi_cortex_m0plus_soft` | Cortex-M0+ | soft |
| `romodular_arm_none_eabi_cortex_m3_soft` | Cortex-M3 | soft |
| `romodular_arm_none_eabi_cortex_m4f_hard` | Cortex-M4 | hard, `fpv4-sp-d16` |
| `romodular_arm_none_eabi_cortex_m7f_hard` | Cortex-M7 | hard, `fpv5-d16` |
| `romodular_atmega328p_avrgcc_avr5` | AVR5 | ATmega328P |

Each embedded profile selects `Ninja Multi-Config`, publishes Debug and Release
as configurations, enables compile-command generation, and resolves its
toolchain through `${fileDir}`. This makes the profile location-independent
when included from a pinned submodule.

## Native profiles

Hidden bases cover macOS Arm64/x64, Linux GCC and Clang on x64/Arm64, and
Windows MSVC/Clang x64. They own compiler and architecture selection only.
Consumers remain responsible for validating that the detected processor matches
the public preset identity.

## Migration rule

A consumer first keeps thin local toolchain wrappers that translate its existing
cache variables into `ROMODULAR_*` variables. The public preset then inherits a
shared hidden base while preserving its existing name, build directory, and
project cache options. Local implementations are removed only after compile
commands, flags, artifact architecture/ABI, and package-consumer evidence match.
