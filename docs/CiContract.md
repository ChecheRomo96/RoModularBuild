# CI contract

Version `0.4.0` exposes reusable CI implementation as composite actions inside
the pinned RoModularBuild checkout. It does not publish a complete consumer
workflow or take ownership of repository policy.

## Single authoritative pin

A consumer records one exact tagged RoModularBuild commit as a Git submodule.
Its workflow checks out submodules recursively and invokes an action by local
path:

```yaml
steps:
  - uses: actions/checkout@<pinned-third-party-sha>
    with:
      submodules: recursive

  - uses: ./tools/RoModularBuild/actions/project-workflow
    with:
      command: test
      preset: linux_gcc_x64
      configuration: Debug
      fresh: true
      parallel: 4
```

The action implementation therefore comes from the exact gitlink already
reviewed by the consumer. Consumers do not add an independent floating branch,
tag, or remote-workflow reference for the same RoModularBuild revision.

## `project-workflow`

`actions/project-workflow` selects Bash on Unix runners and PowerShell on
Windows runners. It calls the consumer's thin adapter in `scripts/` by default.
The supported commands and inputs map directly to the workflow contract:

| Command | Supported inputs |
| --- | --- |
| `configure` | `preset`, `fresh` |
| `build` | `preset`, `configuration`, `target`, `parallel`, `clean-first`, `fresh`, `examples-on` |
| `test` | `preset`, `configuration`, `parallel`, `filter`, `junit`, `fresh`, `allow-no-tests` |
| `install` | `preset`, `prefix` |
| `clean` | `preset` or `all`, plus optional `dist` |

`project-directory` and `script-directory` support a consumer whose adapter is
not at the workspace root or in the default `scripts/` directory. The action
does not accept an arbitrary shell command and does not interpret consumer
feature names.

## `report-toolchain`

`actions/report-toolchain` reports CMake, optional Ninja, the selected compiler,
and the hosted operating system. On Windows, `msvc` reports the installed Visual
Studio toolset through `vswhere`, while `clang` reports `clang++`.

## Consumer-owned workflow policy

The calling repository retains:

- event triggers and concurrency;
- runner versions and job matrices;
- permissions, environments, and secrets;
- dependency installation;
- package, example, coverage, and firmware validation;
- artifact names, paths, and retention;
- documentation deployment; and
- release publication.

Third-party actions have their own dependency pins. They are intentionally not
coupled to the RoModularBuild gitlink and should be reviewed independently.
