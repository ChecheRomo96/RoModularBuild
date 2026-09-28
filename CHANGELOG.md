# Changelog

All notable changes to RoModularBuild are recorded here.

## [0.2.1] - 2026-09-28

### Fixed

- remove unused informational cache variables from hidden preset bases so
  consumer projects configure without spurious CMake warnings.

## [0.2.0] - 2026-09-28

### Added

- project-independent GNU Arm Embedded and AVR-GCC toolchain implementations;
- Cortex-M0+/soft, Cortex-M3/soft, Cortex-M4F/hard, Cortex-M7F/hard, and
  ATmega328P/AVR5 profiles;
- hidden native bases for supported macOS, Linux, and Windows compiler and
  architecture identities;
- standalone semantic tests for every embedded profile; and
- a documented `ROMODULAR_*` toolchain contract for consumer adapters.

## [0.1.1] - 2026-09-28

### Fixed

- use explicit Bash and PowerShell validation steps so GitHub Actions can
  validate and expand the three-platform job matrix; and
- invoke CTest directly so repository tests are independent of generator-
  specific target names.

## [0.1.0] - 2026-09-28

### Added

- independent repository bootstrap and restricted-use license;
- authoritative `VERSION` file and CMake version consistency check;
- hidden native, Arm GNU, and AVR GNU preset namespaces;
- Bash and PowerShell validation entrypoints;
- cross-platform repository self-tests; and
- architecture, ownership, distribution, and migration documentation.
