#!/bin/sh
set -eu
ACTION= PROGRAMMER= FILE= ADDRESS= SIZE=0 FREQUENCY=1000 PROBE= LOG=
fail() { printf 'error: %s\n' "$1" >&2; exit 1; }
while [ "$#" -gt 0 ]; do
    [ "$#" -ge 2 ] || fail "each option requires a value"
    case "$1" in
        --action) ACTION=$2 ;; --programmer) PROGRAMMER=$2 ;; --file) FILE=$2 ;;
        --address) ADDRESS=$2 ;; --size) SIZE=$2 ;; --frequency) FREQUENCY=$2 ;;
        --probe-serial) PROBE=$2 ;; --log) LOG=$2 ;; *) fail "unknown option: $1" ;;
    esac
    shift 2
done
[ -n "$PROGRAMMER" ] && [ -n "$FILE" ] || fail "--programmer and --file are required"
case "$FREQUENCY" in ''|*[!0-9]*) fail "invalid frequency" ;; esac
[ "$FREQUENCY" -ge 100 ] && [ "$FREQUENCY" -le 4000 ] || fail "frequency must be 100..4000 kHz"
if [ -n "$ADDRESS" ]; then
    case "$ADDRESS" in 0x*) HEX=${ADDRESS#0x} ;; *) fail "invalid address" ;; esac
    case "$HEX" in ''|*[!0-9a-fA-F]*) fail "invalid address" ;; esac
    [ "${#HEX}" -le 8 ] || fail "address exceeds 32 bits"
fi
set -- -c port=SWD "freq=$FREQUENCY"
[ -z "$PROBE" ] || set -- "$@" "sn=$PROBE"
case "$ACTION" in
    flash|Flash)
        [ -f "$FILE" ] || fail "firmware file not found"
        case "$FILE" in *.bin) [ -n "$ADDRESS" ] || fail "binary flash requires --address" ;; esac
        set -- "$@" -w "$FILE"
        [ -z "$ADDRESS" ] || set -- "$@" "$ADDRESS"
        set -- "$@" -v -rst ;;
    read|Read)
        case "$SIZE" in ''|*[!0-9]*) fail "invalid size" ;; esac
        [ -n "$ADDRESS" ] && [ "$SIZE" -gt 0 ] && [ "$SIZE" -le 4294967295 ] || fail "read requires address and a positive 32-bit size"
        [ ! -d "$FILE" ] || fail "read destination is a directory"
        mkdir -p "$(dirname "$FILE")"
        # Remove a stale file only; never recursively remove a destination.
        [ ! -e "$FILE" ] || rm -f -- "$FILE"
        set -- "$@" mode=HOTPLUG -u "$ADDRESS" "$SIZE" "$FILE" ;;
    *) fail "--action must be flash or read" ;;
esac
if [ -n "$LOG" ]; then
    mkdir -p "$(dirname "$LOG")"
    printf '%s\n' "$@" > "$LOG.command.txt"
    # Keep the programmer's exit status; a tee pipeline would mask it in POSIX sh.
    if "$PROGRAMMER" "$@" > "$LOG" 2>&1; then cat "$LOG"; else cat "$LOG"; fail "ST-LINK $ACTION failed"; fi
else
    "$PROGRAMMER" "$@" || fail "ST-LINK $ACTION failed"
fi
case "$ACTION" in read|Read)
    [ -f "$FILE" ] && [ "$(wc -c < "$FILE" | tr -d ' ')" -eq "$SIZE" ] || fail "incomplete memory read" ;;
esac
