#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

usage() {
    printf '%s\n' "Usage: ${ROMODULAR_COMMAND_NAME:-$0} <preset> [--prefix <path>]"
}

PRESET=""
PREFIX=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --prefix)
            romodular_require_value "$1" "${2:-}"
            PREFIX=$2
            shift 2
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
romodular_require_configured "$PRESET"

BUILD_DIR=$(romodular_build_dir "$PRESET")
[ -n "$PREFIX" ] || PREFIX="$ROMODULAR_DIST_ROOT/$PRESET"
PREFIX=$(romodular_absolute_path "$PREFIX")

set -- cmake --install "$BUILD_DIR" --prefix "$PREFIX"
set -- "$@" --config "${ROMODULAR_INSTALL_CONFIGURATION:-Release}"

"$@"
