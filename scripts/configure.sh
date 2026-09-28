#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

usage() {
    printf '%s\n' "Usage: ${ROMODULAR_COMMAND_NAME:-$0} <preset> [--fresh] [-- <additional cmake configure arguments>]"
}

PRESET=""
FRESH=0

while [ "$#" -gt 0 ]; do
    case "$1" in
        --fresh)
            FRESH=1
            shift
            ;;
        --)
            shift
            break
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

if [ "$FRESH" -eq 1 ]; then
    BUILD_DIR=$(romodular_build_dir "$PRESET")
    cmake -E remove_directory "$BUILD_DIR"
fi

cmake --preset "$PRESET" "$@"
