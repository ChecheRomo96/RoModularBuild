---
layout: default
title: RoModularBuild documentation
---

# RoModularBuild

Shared CMake presets, toolchain profiles, and build workflows for projects
that pin an exact tagged RoModularBuild revision. The current release is
**0.5.0**. Reusable STM32 board support and ST-LINK operations are described
in [EmbeddedContract.md](EmbeddedContract.md).

RoModularBuild supplies the generic configure, build, test, install, and clean
mechanics. Each consuming project owns its public presets, feature options,
tests, installed packages, and release policy.

## Documentation

| Guide | What it covers |
| --- | --- |
| [Architecture](Architecture.md) | Dependency direction and the responsibilities of the shared layer and its consumers. |
| [Bootstrap contract](BootstrapContract.md) | Naming conventions, tagged submodule pins, versioning, and repository validation. |
| [Toolchain contract](ToolchainContract.md) | Hidden native and embedded profiles, architecture settings, and shared CMake variables. |
| [Workflow contract](WorkflowContract.md) | Consumer adapter inputs, Bash/PowerShell commands, configurations, installation, and cleanup. |
| [CI contract](CiContract.md) | Reusable composite actions and integration through the consumer's single dependency pin. |

## Getting started

1. Read the architecture and bootstrap contracts to establish the repository
   boundary and pinning rules.
2. Initialize the consuming project's pinned submodule:

   ```text
   git submodule update --init --recursive
   ```

3. List the consuming project's public presets from its repository root:

   ```text
   cmake --list-presets
   ```

4. Use that project's adapters under `scripts/`. Select a preset exposed by
   that project; the shared `romodular_` presets are hidden inheritance bases.

For example, from a consumer repository with a public preset named
`<preset>`, PowerShell uses:

```powershell
./scripts/configure.ps1 <preset>
./scripts/build.ps1 <preset> -Configuration Debug
./scripts/test.ps1 <preset> -Configuration Debug
./scripts/build.ps1 <preset> -Configuration Release
./scripts/test.ps1 <preset> -Configuration Release
./scripts/install.ps1 <preset>
```

The corresponding Bash commands are:

```bash
./scripts/configure.sh <preset>
./scripts/build.sh <preset> --config Debug
./scripts/test.sh <preset> --config Debug
./scripts/build.sh <preset> --config Release
./scripts/test.sh <preset> --config Release
./scripts/install.sh <preset>
```

Replace `<preset>` with an actual public preset name before running these
commands. CMake 3.25 or newer and the selected compiler/toolchain are required.
Individual consumers may require additional dependencies. Installation uses
Release by default and requires its artifacts to have been built first.

## Validate RoModularBuild itself

Run from the RoModularBuild repository root on Windows:

```powershell
./scripts/validate.ps1
```

Or with Bash on Linux or macOS:

```bash
./scripts/validate.sh
```

These commands exercise repository contracts and the generic lifecycle.
The self-test project does not compile a real consumer library; consumer
builds, package consumption, and hardware execution need their own evidence.

[Source repository](https://github.com/ChecheRomo96/RoModularBuild)
