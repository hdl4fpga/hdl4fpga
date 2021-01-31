#!/bin/bash
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
PKMODE="STREAM"
export TTY SPEED PKMODE

ADDR="${ADDR:-${1}}"
ADDR="${ADDR:-0}"
ADDR="$((${ADDR} | (1 << 31)))"
ADDR=`printf %08x ${ADDR}`
ADDR="${ADDR: -6}"

LENGTH="${LENGTH:-${2}}"
LENGTH="${LENGTH:-0}"
LENGTH=`printf %06x ${LENGTH}`
LENGTH="${LENGTH: -6}"
echo "1603${ADDR}1702${LENGTH}"|xxd -r -ps|./scripts/siocomms.sh
