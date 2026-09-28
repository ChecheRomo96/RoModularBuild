# Bootstrap contract

Version `0.1.0` establishes the repository boundary without migrating consumer
behavior.

## Naming

- shared preset names begin with `romodular_`;
- shared CMake cache variables begin with `ROMODULAR_`;
- shared shell functions begin with `romodular_`; and
- generic implementation files contain no consumer-prefixed identifiers.

## Pinning

Consumers integrate RoModularBuild as a Git submodule at a stable relative path
and pin a commit belonging to a tagged release. Floating branches are forbidden.
This is required because CMake needs preset and toolchain files before project
configuration, earlier than `FetchContent` can make them available.

## Versioning

RoModularBuild uses independent semantic versions. The `VERSION` file is the
single version source for the repository itself. `0.x` releases may evolve the
adapter contract. A future `1.x` release freezes the supported integration
surface.

## Validation

The repository must validate on macOS, Linux, and Windows. Bash and PowerShell
entrypoints perform the same sequence:

1. validate their native script syntax;
2. ask CMake to parse every preset include;
3. configure the standalone self-test preset;
4. build the self-test project; and
5. run the repository contract through CTest.

This bootstrap does not claim that production toolchains or workflow engines
have been extracted. Those are separate migrations with before-and-after
evidence and consumer rollback points.
