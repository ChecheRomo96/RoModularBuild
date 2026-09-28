#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

sh -n scripts/common.sh scripts/validate.sh
romodular_run_cmake --list-presets=all
romodular_run_cmake --preset romodular_selftest --fresh
romodular_run_cmake --build --preset romodular_selftest
romodular_run_cmake --build build/selftest --target test

printf '%s\n' "RoModularBuild validation passed."
