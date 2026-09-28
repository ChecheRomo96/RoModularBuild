# Changelog

All notable changes to RoModularBuild are recorded here.

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
