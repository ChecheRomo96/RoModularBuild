# Changelog

All notable changes to RoModularBuild are recorded here.

## [0.4.0] - 2026-09-28

### Added

- a cross-platform `project-workflow` composite action for the pinned
  configure, build, test, install, and clean adapter commands;
- a project-independent `report-toolchain` composite action for native hosted
  runners;
- hosted Linux, macOS, and Windows acceptance coverage for the
  composite-action contract;
  and
- a CI contract that retains triggers, runners, permissions, artifacts,
  packaging, and release policy in each consumer repository.

## [0.3.0] - 2026-09-28

### Added

- project-independent configure, build, test, install, and clean workflow
  engines for Bash and PowerShell;
- an adapter contract for consumer roots, configurations, tests, examples, and
  public command hints;
- cross-platform lifecycle validation covering full fresh-state removal,
  Debug builds, JUnit output, Release installation, scoped cleanup, and the
  explicit empty-test-suite policy; and
- a workflow contract that keeps packaging, releases, and project-specific
  options in each consumer repository.

## [0.2.3] - 2026-09-28

### Fixed

- declare the repository's CMake policy baseline in standalone toolchain tests
  so `IN_LIST` validation behaves consistently on every hosted runner.

## [0.2.2] - 2026-09-28

### Fixed

- forward every configurable embedded toolchain input into CMake
  `try_compile()` projects, allowing generic toolchains to be configured
  directly through `ROMODULAR_*` cache variables.

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
