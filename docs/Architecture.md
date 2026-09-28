# Architecture

RoModularBuild is a one-way dependency of consumer repositories. It must never
depend on a consumer's source code, target names, package layout, release
policy, or hardware fixtures.

```text
RoModularBuild tagged revision
        |
        v
consumer-owned preset and script adapter
        |
        v
consumer source, tests, examples, packages, and documentation
        |
        v
optional firmware and hardware validation fixture
```

## Shared ownership

The shared layer may own:

- generic compiler discovery and toolchain mechanics;
- CPU, architecture, ABI, FPU, and sysroot configuration;
- hidden native and cross-compilation preset bases;
- argument validation and safe build-directory handling;
- generic configure, build, test, install, and clean execution; and
- reusable CI implementation after the workflow contract is stable.

## Consumer ownership

Every consumer retains:

- its public preset names and feature defaults;
- source modules, dependencies, tests, and examples;
- installed CMake package names and exported targets;
- package validation and release policy;
- documentation publication and repository permissions; and
- exact MCU startup, linker scripts, SDK integration, flashing, and hardware
  evidence.

## Compatibility identity

Native profiles are identified by operating system, architecture, and compiler.
Generic Arm profiles are identified by core, float ABI, FPU, compiler runtime,
and relevant flags. AVR may require the exact MCU because `-mmcu` selects
device-specific code generation and runtime behavior. Firmware remains an exact
MCU or board concern.

Debug and Release are configurations of one compatibility profile, not separate
preset or package identities.

The lifecycle scripts are engine entrypoints, not consumer-facing policy. A
consumer keeps its established commands and forwards them through a small
adapter that supplies project roots and optional cache arguments. Package
creation, package identity checks, examples, documentation, and release
publication remain consumer-owned orchestration.
