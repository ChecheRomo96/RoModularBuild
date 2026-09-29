#!/bin/sh
set -eu

case "${ROMODULAR_CI_REQUIRE_NINJA:-true}" in
    true|false)
        ;;
    *)
        printf '%s\n' \
            "error: require-ninja must be true or false, got '${ROMODULAR_CI_REQUIRE_NINJA}'" \
            >&2
        exit 2
        ;;
esac

[ -n "${ROMODULAR_CI_COMPILER:-}" ] || {
    printf '%s\n' "error: compiler is required" >&2
    exit 2
}

cmake --version
[ "$ROMODULAR_CI_REQUIRE_NINJA" = false ] || ninja --version
"$ROMODULAR_CI_COMPILER" --version
uname -a
