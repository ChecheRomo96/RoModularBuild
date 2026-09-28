# Toolchains

This directory contains the project-independent toolchains introduced in
version `0.2.0`. Generic implementations own compiler discovery, architecture,
ABI, sysroot, common code-generation flags, linker garbage collection, and
CMake find-root behavior. Profile files select one tested compatibility
identity and then include the generic implementation.

Toolchains added here must:

- expose only `ROMODULAR_*` configuration variables;
- avoid consumer names, targets, features, and packaging policy;
- define compiler, architecture, ABI, sysroot, and CMake find-root behavior;
- remain independently syntax-testable; and
- preserve the consumer's existing flags during migration.

See [Toolchain contract](../../docs/ToolchainContract.md) for the supported
variables and profile table.
