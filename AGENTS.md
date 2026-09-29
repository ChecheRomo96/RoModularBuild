# RoModularBuild agent instructions

RoModularBuild is the project-independent build infrastructure of the
RoModular ecosystem. Keep it reusable by Foundation, MCC, and future consumer
repositories without importing any consumer's product policy.

## Shared RoModular guidance

Before starting work, look for the shared guidance in
`../RoModularAgents`.

- If it exists and is readable, read `AGENTS.md` and `CONTRACT.md` completely.
- Read `repositories/RoModularBuild.md` for the canonical repository adapter.
- Use the relevant skill under `skills/` when the request matches one.
- If the sibling repository is unavailable, continue with the rules in this
  file and report that the shared guidance was not loaded.

Shared guidance does not expand the user's requested scope. Do not modify a
consumer repository or update its pinned RoModularBuild revision unless the
user explicitly includes that repository.

## Repository rules

- Preserve the one-way dependency from consumer repositories to
  RoModularBuild. This repository must not depend on consumer source code,
  target names, package layout, hardware fixtures, or release policy.
- Treat `VERSION` as the authoritative project version. Keep versioned
  contracts, `CHANGELOG.md`, tags, and compatibility claims synchronized.
- Keep shared presets hidden and prefixed with `romodular_`; keep shared cache
  variables prefixed with `ROMODULAR_`.
- Keep public consumer preset names, feature defaults, package creation,
  artifacts, CI matrices, releases, firmware startup, linker scripts, SDK
  integration, flashing, and hardware evidence in the consumer repository.
- Preserve behavioral parity between Bash and PowerShell workflow engines.
  A change to a shared lifecycle command normally requires both implementations
  and their contract tests to be updated.
- Treat composite actions under `actions/` as reusable CI primitives, not as
  complete consumer workflows. Consumers own triggers, permissions, matrices,
  secrets, and deployment.
- Consumer repositories pin exact tagged revisions. Do not make consumers
  follow `main`, and do not update a consumer gitlink as an incidental part of
  infrastructure work.
- Keep architecture and interface changes synchronized with the contracts
  under `docs/` and with repository self-validation.
- Preserve unrelated work and do not commit, tag, push, publish, or merge
  unless the user explicitly requests it.

## Supported entry points

Validate the complete repository contract on the current host:

```text
./scripts/validate.sh
.\scripts\validate.ps1
```

The generic `configure`, `build`, `test`, `install`, and `clean` scripts are
workflow engines. When testing them against a consumer, use that consumer's
thin adapter and pinned submodule revision rather than bypassing its public
commands.

Run the smallest relevant validation first, then broaden it according to risk.
State clearly when PowerShell, Windows, a cross-compiler, or a consumer
validation was not available on the current host.
