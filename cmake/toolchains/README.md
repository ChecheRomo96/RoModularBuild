# Toolchains

This directory is reserved for the project-independent toolchains extracted in
phase 2. Version `0.1.1` intentionally contains no production toolchain: the
bootstrap must first prove repository ownership, naming, versioning, and
validation without changing any consumer behavior.

Toolchains added here must:

- expose only `ROMODULAR_*` configuration variables;
- avoid consumer names, targets, features, and packaging policy;
- define compiler, architecture, ABI, sysroot, and CMake find-root behavior;
- remain independently syntax-testable; and
- preserve the consumer's existing flags during migration.
