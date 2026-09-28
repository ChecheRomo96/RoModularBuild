# RoModularBuild

RoModularBuild is the versioned, project-independent build infrastructure for
RoModular CMake repositories. It is being extracted incrementally so projects
can share native and embedded toolchain profiles and workflow behavior without
sharing project policy.

## Current status

Version `0.2.0` adds project-independent native, GNU Arm Embedded, and AVR-GCC
profiles. The repository now owns generic compiler, architecture, ABI, and
find-root behavior, but it does **not** own consumer feature options, public
preset names, packaging, firmware, or release policy.

The implementation progresses in independently reviewable phases:

1. bootstrap and self-validation;
2. toolchains and hidden preset bases;
3. configure, build, test, install, and clean workflow engines;
4. reusable CI; and
5. adoption by two independent consumers.

See [Architecture](docs/Architecture.md) and
[Bootstrap contract](docs/BootstrapContract.md). The supported shared variables,
profiles, and compatibility boundary are documented in
[Toolchain contract](docs/ToolchainContract.md).

## Validate this repository

On macOS or Linux:

```sh
./scripts/validate.sh
```

On Windows PowerShell:

```powershell
.\scripts\validate.ps1
```

Both commands validate the repository contract, CMake preset schema, configure
the self-test project, and run its CTest suite. They do not build or modify a
consumer project.

## Consumer contract

- Consumers pin an exact tagged revision; they never follow `main`.
- Public consumer presets remain in the consumer repository.
- Shared presets are hidden and use the `romodular_` name prefix.
- Shared cache variables use the `ROMODULAR_` prefix.
- Project options, packaging, releases, examples, firmware startup, linker
  scripts, and hardware evidence remain owned by each consumer.
- Existing consumer commands must remain functional while migration is in
  progress.

## License

All rights are reserved. Viewing the repository does not grant permission to
use, compile, copy, modify, or distribute it. See [LICENSE](LICENSE).
