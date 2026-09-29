# Workflow contract

Version `0.4.0` owns the generic configure, build, test, install, and clean
lifecycle for CMake preset consumers. A consumer exposes its existing public
commands through thin repository-local wrappers and configures the engine with
environment variables.

## Required adapter input

| Variable | Meaning | Default |
| --- | --- | --- |
| `ROMODULAR_PROJECT_ROOT` | Absolute consumer source root containing `CMakePresets.json` | RoModularBuild root |
| `ROMODULAR_BUILD_ROOT` | Consumer build-tree root | `<project>/build` |
| `ROMODULAR_DIST_ROOT` | Consumer install/export root | `<project>/dist` |

## Optional adapter input

| Variable | Meaning | Default |
| --- | --- | --- |
| `ROMODULAR_PROJECT_LABEL` | Name used in diagnostics | `project` |
| `ROMODULAR_CONFIGURE_COMMAND` | Public command shown by missing-configuration diagnostics | `scripts/configure.sh` or `scripts/configure.ps1` |
| `ROMODULAR_DEFAULT_CONFIGURATION` | Configuration selected when none is supplied | `Debug` |
| `ROMODULAR_DOCUMENTATION_PRESET` | Preset that uses the documentation configuration | unset |
| `ROMODULAR_DOCUMENTATION_CONFIGURATION` | Default configuration for that preset | `Release` |
| `ROMODULAR_INSTALL_CONFIGURATION` | Configuration installed by the install workflow | `Release` |
| `ROMODULAR_TESTING_CACHE_ARGUMENT` | One consumer cache argument that enables tests | unset |
| `ROMODULAR_EXAMPLES_CACHE_ARGUMENT` | One consumer cache argument used by `--examples-on` | unset |
| `ROMODULAR_COMMAND_NAME` | Public Bash wrapper name displayed by `--help` | engine path |

The two cache arguments are deliberately consumer values. The engine knows
that a test workflow may require tests and that a build may opt into examples;
it does not know any consumer option prefix or target name.

## Stable lifecycle behavior

- configure selects exactly one public consumer preset and forwards raw CMake
  arguments after `--`;
- fresh configure removes the complete `build/<preset>` tree before invoking
  CMake, preventing stale cache or artifact reuse;
- build configures first and then supports configuration, target, parallel,
  clean-first, fresh, and optional examples selection;
- test configures, builds, and runs CTest with no-tests-as-error by default;
- `--allow-no-tests` / `-AllowNoTests` is an explicit diagnostic escape hatch;
- install requires an existing configured tree and installs Release into
  `dist/<preset>` unless an explicit prefix is supplied; and
- clean removes one preset or all build trees, while distributions are removed
  only when explicitly requested.

Debug and Release remain configurations within one preset identity. The engine
does not create packages, publish releases, validate consumer metadata, select
firmware startup code, or define public preset names.
