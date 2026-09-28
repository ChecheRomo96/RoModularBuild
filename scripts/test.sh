#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

usage() {
    printf '%s\n' "Usage: ${ROMODULAR_COMMAND_NAME:-$0} <preset> [--config <name>] [--parallel <jobs>] [--filter <regex>] [--junit <path>] [--fresh] [--allow-no-tests]"
}

PRESET=""
CONFIGURATION=""
PARALLEL=""
FILTER=""
JUNIT=""
FRESH=0
ALLOW_NO_TESTS=0

while [ "$#" -gt 0 ]; do
    case "$1" in
        --config)
            romodular_require_value "$1" "${2:-}"
            CONFIGURATION=$2
            shift 2
            ;;
        --parallel)
            romodular_require_value "$1" "${2:-}"
            PARALLEL=$2
            shift 2
            ;;
        --filter)
            romodular_require_value "$1" "${2:-}"
            FILTER=$2
            shift 2
            ;;
        --junit)
            romodular_require_value "$1" "${2:-}"
            JUNIT=$2
            shift 2
            ;;
        --fresh)
            FRESH=1
            shift
            ;;
        --allow-no-tests)
            ALLOW_NO_TESTS=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            romodular_die "unknown option: $1"
            ;;
        *)
            [ -z "$PRESET" ] || romodular_die "only one preset may be specified"
            PRESET=$1
            shift
            ;;
    esac
done

romodular_require_preset "$PRESET"
romodular_require_command ctest

BUILD_DIR=$(romodular_build_dir "$PRESET")
CONFIGURATION=$(romodular_configuration "$PRESET" "$CONFIGURATION" "Debug")
romodular_require_configuration "$CONFIGURATION"

if [ -n "$JUNIT" ]; then
    JUNIT=$(romodular_absolute_path "$JUNIT")
fi

set -- "$SCRIPT_DIR/configure.sh" "$PRESET"
[ "$FRESH" -eq 0 ] || set -- "$@" --fresh
if [ -n "${ROMODULAR_TESTING_CACHE_ARGUMENT:-}" ]; then
    set -- "$@" -- "$ROMODULAR_TESTING_CACHE_ARGUMENT"
fi
"$@"

[ -z "$JUNIT" ] || cmake -E make_directory "$(dirname -- "$JUNIT")"

set -- cmake --build "$BUILD_DIR" --config "$CONFIGURATION"
[ -z "$PARALLEL" ] || set -- "$@" --parallel "$PARALLEL"
"$@"

set -- ctest --test-dir "$BUILD_DIR" --output-on-failure
[ "$ALLOW_NO_TESTS" -eq 1 ] || set -- "$@" --no-tests=error
set -- "$@" --build-config "$CONFIGURATION"
[ -z "$PARALLEL" ] || set -- "$@" --parallel "$PARALLEL"
[ -z "$FILTER" ] || set -- "$@" --tests-regex "$FILTER"
[ -z "$JUNIT" ] || set -- "$@" --output-junit "$JUNIT"
"$@"
