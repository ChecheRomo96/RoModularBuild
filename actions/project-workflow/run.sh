#!/bin/sh
set -eu

romodular_ci_die() {
    printf '%s\n' "error: $*" >&2
    exit 2
}

romodular_ci_require_boolean() {
    case "$2" in
        true|false)
            ;;
        *)
            romodular_ci_die "$1 must be true or false, got '$2'"
            ;;
    esac
}

romodular_ci_require_preset() {
    [ -n "$ROMODULAR_CI_PRESET" ] ||
        romodular_ci_die "command '$ROMODULAR_CI_COMMAND' requires a preset"
}

romodular_ci_project_directory=${ROMODULAR_CI_PROJECT_DIRECTORY:-.}
romodular_ci_script_directory=${ROMODULAR_CI_SCRIPT_DIRECTORY:-scripts}

cd "$romodular_ci_project_directory" ||
    romodular_ci_die "cannot enter project directory: $romodular_ci_project_directory"

romodular_ci_require_boolean \
    ROMODULAR_CI_FRESH "${ROMODULAR_CI_FRESH:-false}"
romodular_ci_require_boolean \
    ROMODULAR_CI_CLEAN_FIRST "${ROMODULAR_CI_CLEAN_FIRST:-false}"
romodular_ci_require_boolean \
    ROMODULAR_CI_EXAMPLES_ON "${ROMODULAR_CI_EXAMPLES_ON:-false}"
romodular_ci_require_boolean \
    ROMODULAR_CI_ALLOW_NO_TESTS "${ROMODULAR_CI_ALLOW_NO_TESTS:-false}"
romodular_ci_require_boolean ROMODULAR_CI_DIST "${ROMODULAR_CI_DIST:-false}"
romodular_ci_require_boolean ROMODULAR_CI_ALL "${ROMODULAR_CI_ALL:-false}"

case "${ROMODULAR_CI_PARALLEL:-0}" in
    ''|*[!0-9]*)
        romodular_ci_die "parallel must be a non-negative integer"
        ;;
esac

case "${ROMODULAR_CI_COMMAND:-}" in
    configure)
        romodular_ci_require_preset
        set -- "./$romodular_ci_script_directory/configure.sh" \
            "$ROMODULAR_CI_PRESET"
        [ "${ROMODULAR_CI_FRESH:-false}" = false ] || set -- "$@" --fresh
        ;;
    build)
        romodular_ci_require_preset
        set -- "./$romodular_ci_script_directory/build.sh" \
            "$ROMODULAR_CI_PRESET"
        [ -z "${ROMODULAR_CI_CONFIGURATION:-}" ] ||
            set -- "$@" --config "$ROMODULAR_CI_CONFIGURATION"
        [ -z "${ROMODULAR_CI_TARGET:-}" ] ||
            set -- "$@" --target "$ROMODULAR_CI_TARGET"
        [ "${ROMODULAR_CI_PARALLEL:-0}" -eq 0 ] ||
            set -- "$@" --parallel "$ROMODULAR_CI_PARALLEL"
        [ "${ROMODULAR_CI_CLEAN_FIRST:-false}" = false ] ||
            set -- "$@" --clean-first
        [ "${ROMODULAR_CI_FRESH:-false}" = false ] || set -- "$@" --fresh
        [ "${ROMODULAR_CI_EXAMPLES_ON:-false}" = false ] ||
            set -- "$@" --examples-on
        ;;
    test)
        romodular_ci_require_preset
        set -- "./$romodular_ci_script_directory/test.sh" \
            "$ROMODULAR_CI_PRESET"
        [ -z "${ROMODULAR_CI_CONFIGURATION:-}" ] ||
            set -- "$@" --config "$ROMODULAR_CI_CONFIGURATION"
        [ "${ROMODULAR_CI_PARALLEL:-0}" -eq 0 ] ||
            set -- "$@" --parallel "$ROMODULAR_CI_PARALLEL"
        [ -z "${ROMODULAR_CI_FILTER:-}" ] ||
            set -- "$@" --filter "$ROMODULAR_CI_FILTER"
        [ -z "${ROMODULAR_CI_JUNIT:-}" ] ||
            set -- "$@" --junit "$ROMODULAR_CI_JUNIT"
        [ "${ROMODULAR_CI_FRESH:-false}" = false ] || set -- "$@" --fresh
        [ "${ROMODULAR_CI_ALLOW_NO_TESTS:-false}" = false ] ||
            set -- "$@" --allow-no-tests
        ;;
    install)
        romodular_ci_require_preset
        set -- "./$romodular_ci_script_directory/install.sh" \
            "$ROMODULAR_CI_PRESET"
        [ -z "${ROMODULAR_CI_PREFIX:-}" ] ||
            set -- "$@" --prefix "$ROMODULAR_CI_PREFIX"
        ;;
    clean)
        set -- "./$romodular_ci_script_directory/clean.sh"
        if [ "${ROMODULAR_CI_ALL:-false}" = true ]; then
            [ -z "${ROMODULAR_CI_PRESET:-}" ] ||
                romodular_ci_die "clean cannot combine a preset with all=true"
            set -- "$@" --all
        else
            romodular_ci_require_preset
            set -- "$@" "$ROMODULAR_CI_PRESET"
        fi
        [ "${ROMODULAR_CI_DIST:-false}" = false ] || set -- "$@" --dist
        ;;
    *)
        romodular_ci_die \
            "unsupported command '${ROMODULAR_CI_COMMAND:-}'; expected configure, build, test, install, or clean"
        ;;
esac

"$@"
