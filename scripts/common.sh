#!/bin/sh

ROMODULAR_SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROMODULAR_ROOT=$(CDPATH= cd -- "$ROMODULAR_SCRIPT_DIR/.." && pwd)
ROMODULAR_PROJECT_ROOT=${ROMODULAR_PROJECT_ROOT:-$ROMODULAR_ROOT}
ROMODULAR_BUILD_ROOT=${ROMODULAR_BUILD_ROOT:-$ROMODULAR_PROJECT_ROOT/build}
ROMODULAR_DIST_ROOT=${ROMODULAR_DIST_ROOT:-$ROMODULAR_PROJECT_ROOT/dist}
ROMODULAR_PROJECT_LABEL=${ROMODULAR_PROJECT_LABEL:-project}
ROMODULAR_CONFIGURE_COMMAND=${ROMODULAR_CONFIGURE_COMMAND:-scripts/configure.sh}

romodular_die() {
    printf '%s\n' "error: $*" >&2
    exit 2
}

romodular_require_command() {
    command -v "$1" >/dev/null 2>&1 || romodular_die "required command not found: $1"
}

romodular_require_value() {
    [ "$#" -ge 2 ] || romodular_die "internal error: romodular_require_value expects a flag and value"
    [ -n "$2" ] || romodular_die "$1 requires a value"
}

romodular_require_preset() {
    [ -n "${1:-}" ] || romodular_die "a CMake configure preset is required"
    case "$1" in
        [A-Za-z0-9]*)
            ;;
        *)
            romodular_die "invalid preset name: $1"
            ;;
    esac
    case "$1" in
        *..*|*[!A-Za-z0-9_.-]*)
            romodular_die "invalid preset name: $1"
            ;;
    esac
}

romodular_build_dir() {
    printf '%s\n' "$ROMODULAR_BUILD_ROOT/$1"
}

romodular_configuration() {
    if [ -n "${2:-}" ]; then
        printf '%s\n' "$2"
        return
    fi

    if [ -n "${ROMODULAR_DOCUMENTATION_PRESET:-}" ] &&
        [ "$1" = "$ROMODULAR_DOCUMENTATION_PRESET" ]; then
        printf '%s\n' "${ROMODULAR_DOCUMENTATION_CONFIGURATION:-Release}"
        return
    fi

    printf '%s\n' "${3:-${ROMODULAR_DEFAULT_CONFIGURATION:-Debug}}"
}

romodular_require_configuration() {
    case "$1" in
        Debug|Release)
            ;;
        *)
            romodular_die "unsupported configuration '$1'; expected Debug or Release"
            ;;
    esac
}

romodular_require_configured() {
    BUILD_DIR=$(romodular_build_dir "$1")
    [ -f "$BUILD_DIR/CMakeCache.txt" ] ||
        romodular_die "preset '$1' is not configured; run $ROMODULAR_CONFIGURE_COMMAND $1 first"
}

romodular_absolute_path() {
    case "$1" in
        /*)
            printf '%s\n' "$1"
            ;;
        *)
            printf '%s\n' "$ROMODULAR_PROJECT_ROOT/$1"
            ;;
    esac
}

romodular_require_safe_dist_child() {
    case "$1" in
        "$ROMODULAR_DIST_ROOT"/*)
            ;;
        *)
            romodular_die "refusing to remove export path outside $ROMODULAR_DIST_ROOT: $1"
            ;;
    esac
}

romodular_run_cmake() {
    cmake "$@" || romodular_die "cmake command failed"
}

romodular_run_ctest() {
    ctest "$@" || romodular_die "ctest command failed"
}

romodular_require_command cmake
cd "$ROMODULAR_PROJECT_ROOT" ||
    romodular_die "cannot enter $ROMODULAR_PROJECT_LABEL root: $ROMODULAR_PROJECT_ROOT"
