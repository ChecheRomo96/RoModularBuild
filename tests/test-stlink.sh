#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FIXTURE=$(mktemp -d)
export ROMODULAR_STLINK_TEST_ARGS="$FIXTURE/arguments.txt"
export ROMODULAR_STLINK_TEST_FAIL=0 ROMODULAR_STLINK_TEST_SHORT=0
cat > "$FIXTURE/programmer" <<'EOF'
#!/bin/sh
printf '%s\n' "$@" > "$ROMODULAR_STLINK_TEST_ARGS"
[ "$ROMODULAR_STLINK_TEST_FAIL" != 1 ] || exit 7
while [ "$#" -gt 0 ]; do
    if [ "$1" = -u ]; then
        count=$3
        [ "$ROMODULAR_STLINK_TEST_SHORT" != 1 ] || count=1
        dd if=/dev/zero of="$4" bs=1 count="$count" 2>/dev/null
        exit 0
    fi
    shift
done
EOF
chmod +x "$FIXTURE/programmer"
printf synthetic > "$FIXTURE/firmware with spaces.elf"
sh "$ROOT/scripts/stlink.sh" --action flash --programmer "$FIXTURE/programmer" --file "$FIXTURE/firmware with spaces.elf" --probe-serial 'probe 3'
grep -Fx 'sn=probe 3' "$ROMODULAR_STLINK_TEST_ARGS" >/dev/null
grep -Fx -- -v "$ROMODULAR_STLINK_TEST_ARGS" >/dev/null
grep -Fx -- -rst "$ROMODULAR_STLINK_TEST_ARGS" >/dev/null
sh "$ROOT/scripts/stlink.sh" --action read --programmer "$FIXTURE/programmer" --file "$FIXTURE/read.bin" --address 0x20000000 --size 8
grep -Fx 'mode=HOTPLUG' "$ROMODULAR_STLINK_TEST_ARGS" >/dev/null
ROMODULAR_STLINK_TEST_FAIL=1
if sh "$ROOT/scripts/stlink.sh" --action read --programmer "$FIXTURE/programmer" --file "$FIXTURE/read.bin" --address 0x20000000 --size 8; then exit 1; fi
[ ! -e "$FIXTURE/read.bin" ]
ROMODULAR_STLINK_TEST_FAIL=0 ROMODULAR_STLINK_TEST_SHORT=1
if sh "$ROOT/scripts/stlink.sh" --action read --programmer "$FIXTURE/programmer" --file "$FIXTURE/read.bin" --address 0x20000000 --size 8; then exit 1; fi
ROMODULAR_STLINK_TEST_SHORT=0
if sh "$ROOT/scripts/stlink.sh" --action read --programmer "$FIXTURE/programmer" --file "$FIXTURE/read.bin" --address invalid --size 8; then exit 1; fi
if sh "$ROOT/scripts/stlink.sh" --action read --programmer "$FIXTURE/programmer" --file "$FIXTURE/read.bin" --address 0x20000000 --size 0; then exit 1; fi
printf synthetic > "$FIXTURE/input.bin"
if sh "$ROOT/scripts/stlink.sh" --action flash --programmer "$FIXTURE/programmer" --file "$FIXTURE/input.bin"; then exit 1; fi
printf '%s\n' 'ST-LINK shell contract passed (synthetic transport only)'
