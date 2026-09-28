#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

romodular_require_command ctest

sh -n \
    scripts/common.sh \
    scripts/configure.sh \
    scripts/build.sh \
    scripts/test.sh \
    scripts/install.sh \
    scripts/clean.sh \
    scripts/validate.sh
romodular_run_cmake --list-presets=all

./scripts/configure.sh romodular_selftest --fresh
cmake -E touch build/romodular_selftest/stale-before-fresh
./scripts/configure.sh romodular_selftest --fresh
[ ! -e build/romodular_selftest/stale-before-fresh ] ||
    romodular_die "--fresh did not remove the complete preset build tree"

./scripts/build.sh romodular_selftest --config Debug
./scripts/test.sh romodular_selftest \
    --config Debug \
    --junit build/validation/romodular-selftest.xml
[ -f build/validation/romodular-selftest.xml ] ||
    romodular_die "test workflow did not create the requested JUnit report"

./scripts/install.sh romodular_selftest
[ -f dist/romodular_selftest/share/RoModularBuild/VERSION ] ||
    romodular_die "install workflow did not create the expected artifact"

./scripts/clean.sh romodular_selftest
[ ! -d build/romodular_selftest ] ||
    romodular_die "clean workflow did not remove the preset build tree"
[ -d dist/romodular_selftest ] ||
    romodular_die "build-only clean unexpectedly removed the distribution"
./scripts/clean.sh romodular_selftest --dist
[ ! -d dist/romodular_selftest ] ||
    romodular_die "distribution clean did not remove the preset export"

if ./scripts/test.sh romodular_no_tests --fresh; then
    romodular_die "test workflow accepted an empty suite without --allow-no-tests"
fi
./scripts/test.sh romodular_no_tests --allow-no-tests
./scripts/clean.sh romodular_no_tests --dist

printf '%s\n' "RoModularBuild validation passed."
