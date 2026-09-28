#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

usage() {
    printf '%s\n' "Usage: ${ROMODULAR_COMMAND_NAME:-$0} <preset> [--config <name>] [--target <name>] [--parallel <jobs>] [--clean-first] [--fresh] [--examples-on]"
}

PRESET=""
CONFIGURATION=""
TARGET=""
PARALLEL=""
CLEAN_FIRST=0
FRESH=0
EXAMPLES_ON=0

while [ "$#" -gt 0 ]; do
    case "$1" in
        --config)
            romodular_require_value "$1" "${2:-}"
            CONFIGURATION=$2
            shift 2
            ;;
        --target)
            romodular_require_value "$1" "${2:-}"
            TARGET=$2
            shift 2
            ;;
        --parallel)
            romodular_require_value "$1" "${2:-}"
            PARALLEL=$2
            shift 2
            ;;
        --clean-first)
            CLEAN_FIRST=1
            shift
            ;;
        --fresh)
            FRESH=1
            shift
            ;;
        --examples-on)
            EXAMPLES_ON=1
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

set -- "$SCRIPT_DIR/configure.sh" "$PRESET"
[ "$FRESH" -eq 0 ] || set -- "$@" --fresh
if [ "$EXAMPLES_ON" -eq 1 ]; then
    [ -n "${ROMODULAR_EXAMPLES_CACHE_ARGUMENT:-}" ] ||
        romodular_die "$ROMODULAR_PROJECT_LABEL does not define an examples cache argument"
    set -- "$@" -- "$ROMODULAR_EXAMPLES_CACHE_ARGUMENT"
fi
"$@"

BUILD_DIR=$(romodular_build_dir "$PRESET")
CONFIGURATION=$(romodular_configuration "$PRESET" "$CONFIGURATION" "Debug")
romodular_require_configuration "$CONFIGURATION"

set -- cmake --build "$BUILD_DIR" --config "$CONFIGURATION"
[ -z "$TARGET" ] || set -- "$@" --target "$TARGET"
[ -z "$PARALLEL" ] || set -- "$@" --parallel "$PARALLEL"
[ "$CLEAN_FIRST" -eq 0 ] || set -- "$@" --clean-first

"$@"
