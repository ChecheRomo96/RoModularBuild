#!/bin/sh
set -eu
TOOL=avrdude DEVICE= PROGRAMMER= PORT= FILE= CONFIG= BAUD=115200 LOG= NO_ERASE=false
fail() { printf 'error: %s\n' "$1" >&2; exit 1; }
while [ "$#" -gt 0 ]; do
    if [ "$1" = --no-erase ]; then NO_ERASE=true; shift; continue; fi
    [ "$#" -ge 2 ] || fail "each option requires a value"
    case "$1" in
        --tool) TOOL=$2 ;; --device) DEVICE=$2 ;; --programmer) PROGRAMMER=$2 ;;
        --port) PORT=$2 ;; --file) FILE=$2 ;; --config) CONFIG=$2 ;;
        --baud) BAUD=$2 ;; --log) LOG=$2 ;; *) fail "unknown option: $1" ;;
    esac
    shift 2
done
[ -n "$DEVICE" ] && [ -n "$PROGRAMMER" ] && [ -n "$PORT" ] || fail "device, programmer and port are required"
[ -f "$FILE" ] || fail "firmware file not found"
case "$FILE" in *.[hH][eE][xX]) ;; *) fail "firmware must be Intel HEX (.hex)" ;; esac
case "$BAUD" in ''|*[!0-9]*) fail "invalid baud" ;; esac
[ "$BAUD" -gt 0 ] && [ "$BAUD" -le 4000000 ] || fail "baud must be 1..4000000"
set -- -p "$DEVICE" -c "$PROGRAMMER" -P "$PORT" -b "$BAUD"
if [ -n "$CONFIG" ]; then
    [ -f "$CONFIG" ] || fail "configuration file not found"
    set -- "$@" -C "$CONFIG"
fi
[ "$NO_ERASE" = false ] || set -- "$@" -D
# avrdude verifies writes by default. Never disable verification or signature checks.
set -- "$@" -U "flash:w:$FILE:i"
if [ -n "$LOG" ]; then
    mkdir -p "$(dirname "$LOG")"
    printf '%s\n' "$@" > "$LOG.command.txt"
    if "$TOOL" "$@" > "$LOG" 2>&1; then cat "$LOG"; else cat "$LOG"; fail "avrdude flash failed"; fi
else
    "$TOOL" "$@"
fi
