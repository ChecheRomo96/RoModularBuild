#!/bin/sh
set -eu
TOOL=simavr MCU= FILE= FREQUENCY=16000000 SECONDS=60 LOG=
fail() { printf 'error: %s\n' "$1" >&2; exit 1; }
while [ "$#" -gt 0 ]; do
    [ "$#" -ge 2 ] || fail "each option requires a value"
    case "$1" in
        --tool) TOOL=$2 ;; --mcu) MCU=$2 ;; --file) FILE=$2 ;;
        --frequency) FREQUENCY=$2 ;; --timeout) SECONDS=$2 ;; --log) LOG=$2 ;;
        *) fail "unknown option: $1" ;;
    esac
    shift 2
done
[ -n "$MCU" ] && [ -f "$FILE" ] && [ -n "$LOG" ] || fail "mcu, existing firmware and log are required"
case "$FREQUENCY:$SECONDS" in *[!0-9:]*|:*|*:) fail "invalid frequency or timeout" ;; esac
[ "$FREQUENCY" -gt 0 ] && [ "$FREQUENCY" -le 100000000 ] && [ "$SECONDS" -gt 0 ] && [ "$SECONDS" -le 3600 ] || fail "invalid frequency or timeout"
mkdir -p "$(dirname "$LOG")"
set -- -m "$MCU" -f "$FREQUENCY" "$FILE"
printf '%s\n' "$@" > "$LOG.command.txt"
# A timeout is a transport failure even if the consumer printed a success marker.
if timeout --kill-after=5 "$SECONDS" "$TOOL" "$@" > "$LOG" 2>&1; then
    cat "$LOG"
else
    STATUS=$?; cat "$LOG"; printf 'simavr failed or timed out (%s)\n' "$STATUS" >&2; exit "$STATUS"
fi
