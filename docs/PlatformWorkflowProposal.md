# Platform workflow proposal

Status: proposed. This document does not expand the supported-platform contract
or claim successful execution on any platform. Implementation and CI evidence
are required before promoting a proposed lane to supported.

## Objective

Make the existing build infrastructure demonstrably usable for desktop
libraries and applications, embedded libraries, and desktop framework consumers
such as JUCE. Preserve the lifecycle commands and the single tagged submodule
pin described in the workflow and CI contracts.

## Starting point

The repository provides native, GNU Arm Embedded, and AVR-GCC profiles and
Bash/PowerShell lifecycle engines. Its validation workflow runs on Linux,
macOS, and Windows. The root self-test project uses `LANGUAGES NONE`; passing
that workflow does not establish that each native compiler profile can compile,
link, install, or consume a C++ library. Embedded support now also has independent AVR and STM32 firmware fixtures
that cross-compile and link, plus AVR simulator and synthetic transport checks.
These do not yet cover every architecture or establish physical device execution.

Linux x64 and Arm64 presets currently select the same compiler executable names
and check the host OS only. Runner architecture and artifact architecture need
explicit verification. Windows MSVC selects a specific Visual Studio generator;
its compatibility with the chosen runner and CMake version also needs evidence.

## Ownership

RoModularBuild owns generic fixtures for testing its own contracts, compiler
discovery, architecture checks, hidden profiles, lifecycle mechanics, reusable
startup/linker/runtime support, artifact conversion, generic programmer transports,
and composite actions. Fixtures must use synthetic source and local target names,
without depending on product repositories.

Consumers own complete workflows: public presets, framework and SDK versions,
dependencies, CI matrices, packaging, plugin formats, signing, deployment,
application firmware, SDK/clock setup, memory budgets, verdict interpretation,
and hardware testing. Examples in
this repository are reference recipes, not remotely invoked product workflows.
Do not change consumer pins as part of this work.

## Proposed workflow families

| Family | Execution | Required evidence |
| --- | --- | --- |
| Desktop | Configure, build, test, install, then build and run a separate package consumer | Real C++ compilation; Debug and Release; compiler and artifact architecture; exported target relocatability |
| Embedded library | Cross-configure and build a small library and compile probe | Compiler identity; target architecture and ABI; expected flags; no host compiler fallback |
| Embedded firmware | Consumer-owned SDK/board build, artifact inspection, optional device execution | Exact MCU/board, startup and linker provenance, memory usage; device result reported separately |
| JUCE integration | Build a minimal desktop application using a pinned JUCE checkout and an installed synthetic package | Successful framework/package linkage; no source-tree dependency; desktop launch checked where practical |

Cross-compiled programs must not be passed to host CTest as executable tests.
Compilation, linking, emulation, and execution on a device are separate evidence
levels. A successful static-library build is not proof of working firmware.

## Delivery sequence

### 1. Establish real desktop coverage

Add a small C++ library fixture with a public header, exported CMake target,
installation rules, and an executable test. Add a separate `find_package`
consumer. Install to a temporary prefix, relocate it, and configure the consumer
without access to the original build tree. Exercise the same lifecycle engines
and composite actions that consumers use.

Start with Windows x64/MSVC, Linux x64/GCC, and macOS Arm64/AppleClang in Debug
and Release. Record actual runner, compiler, CMake, generator, and architecture.
Then add Linux Clang, Windows Clang, macOS x64, and Linux Arm64 when matching
runners and dependencies have been verified. A profile is supported only after
its own lane passes; an OS-level green job does not cover all its profiles.

Acceptance: compilation, executable tests, install, relocated package consumption,
and artifact architecture checks pass for each promoted lane. Bash and
PowerShell retain equivalent lifecycle behavior.

### 2. Establish real cross-compilation coverage

Compile synthetic C/C++ probes through all existing Cortex-M and AVR profiles
with explicitly selected toolchain versions. Inspect object or archive members
using the matching toolchain utilities, checking architecture and ABI as
applicable. Include a negative case for a missing compiler so CI cannot silently
fall back to a host compiler.

Keep firmware recipes distinct and consumer-owned. Introduce a concrete board
recipe only when a consumer selects its SDK and memory constraints; consume
shared startup, linker/runtime and transport mechanics where available. Flashing or hardware availability must not be required for
the generic library lanes.

Acceptance: every promoted profile produces inspected cross-compiled artifacts;
logs distinguish compile-only evidence from linked firmware and hardware tests.

### 3. Prove JUCE interoperability

Begin with a desktop application fixture, using the installed synthetic library
from stage 1 and an exact JUCE revision. The fixture owns JUCE setup and options;
generic toolchain profiles must not introduce JUCE dependencies or product
feature defaults. Run it through consumer-style adapters on the desktop lanes.

After this passes, propose a separate audio-plugin recipe with explicitly chosen
formats and hosts. Decide SDK requirements, licensing, validation tools, signing,
and packaging in the consuming project before claiming plugin support. Do not
equate application linkage with plugin-host or real-time audio validation.

Acceptance: the application builds against the installed package on each
promoted desktop lane, and headless build results are distinguished from GUI
launch checks. Plugin support remains a separate milestone.

### 4. Publish a support matrix and adoption recipes

For each lane record OS, architecture, compiler/version, generator, framework or
SDK revision where applicable, executed checks, and CI evidence. Distinguish
proposed, compile-verified, runtime-verified, and hardware-verified status.

Document consumer-owned desktop, embedded, and JUCE workflow recipes using local
composite-action paths and one exact infrastructure pin. Version implementation
changes according to their compatibility impact; update contracts and changelog
when the changes land. This proposal alone does not require a version bump.

## First implementation slice

Implement stage 1's synthetic desktop fixture and isolated package consumer,
then wire the initial three-platform matrix. Resolve generator and architecture
issues exposed by that evidence before adding more profiles or framework work.
This gives embedded and JUCE work a tested package boundary to build on.
