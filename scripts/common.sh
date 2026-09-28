#!/bin/sh

ROMODULAR_SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROMODULAR_ROOT=$(CDPATH= cd -- "$ROMODULAR_SCRIPT_DIR/.." && pwd)

romodular_die() {
    printf '%s\n' "error: $*" >&2
    exit 2
}

romodular_require_command() {
    command -v "$1" >/dev/null 2>&1 || romodular_die "required command not found: $1"
}

romodular_run_cmake() {
    cmake "$@" || romodular_die "cmake command failed"
}

romodular_run_ctest() {
    ctest "$@" || romodular_die "ctest command failed"
}

romodular_require_command cmake
romodular_require_command ctest
cd "$ROMODULAR_ROOT" || romodular_die "cannot enter repository root: $ROMODULAR_ROOT"
