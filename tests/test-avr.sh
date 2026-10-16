#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
TEMP=$(mktemp -d)
trap 'rm -rf -- "$TEMP"' EXIT HUP INT TERM
export AVR_TEST_ARGS="$TEMP/arguments" AVR_TEST_STATUS=0
printf ':00000001FF\n' > "$TEMP/firmware with spaces.hex"
cat > "$TEMP/tool" <<'SH'
#!/bin/sh
printf '%s\n' "$@" > "$AVR_TEST_ARGS"
printf 'tool output\n'
exit "$AVR_TEST_STATUS"
SH
chmod +x "$TEMP/tool"
sh "$ROOT/scripts/avrdude.sh" --tool "$TEMP/tool" --device atmega2560 --programmer wiring --port COM3 --no-erase --file "$TEMP/firmware with spaces.hex" --log "$TEMP/flash.log"
grep -Fx -- '-D' "$AVR_TEST_ARGS"
grep -Fx -- "flash:w:$TEMP/firmware with spaces.hex:i" "$AVR_TEST_ARGS"
if grep -Ex -- '-V|-F' "$AVR_TEST_ARGS"; then exit 1; fi
export AVR_TEST_STATUS=7
if sh "$ROOT/scripts/avrdude.sh" --tool "$TEMP/tool" --device atmega2560 --programmer wiring --port COM3 --file "$TEMP/firmware with spaces.hex" --log "$TEMP/flash.log"; then exit 1; fi
export AVR_TEST_STATUS=0
sh "$ROOT/scripts/simavr.sh" --tool "$TEMP/tool" --mcu atmega328p --file "$TEMP/firmware with spaces.hex" --log "$TEMP/sim.log"
grep -Fx atmega328p "$AVR_TEST_ARGS"
# Homebrew exposes GNU timeout as gtimeout; exercise that path independently.
mkdir "$TEMP/bin"
for COMMAND in dirname mkdir cat; do ln -s "$(command -v "$COMMAND")" "$TEMP/bin/$COMMAND"; done
ln -s "$(command -v timeout || command -v gtimeout)" "$TEMP/bin/gtimeout"
PATH="$TEMP/bin" /bin/sh "$ROOT/scripts/simavr.sh" --tool "$TEMP/tool" --mcu atmega2560 --file "$TEMP/firmware with spaces.hex" --log "$TEMP/sim.log"
export AVR_TEST_STATUS=7
if sh "$ROOT/scripts/simavr.sh" --tool "$TEMP/tool" --mcu atmega328p --file "$TEMP/firmware with spaces.hex" --log "$TEMP/sim.log"; then exit 1; fi
printf '#!/bin/sh\nexec sleep 10\n' > "$TEMP/tool"
if sh "$ROOT/scripts/simavr.sh" --tool "$TEMP/tool" --mcu atmega328p --file "$TEMP/firmware with spaces.hex" --timeout 1 --log "$TEMP/sim.log"; then exit 1; fi
printf 'AVR transport contract passed\n'
