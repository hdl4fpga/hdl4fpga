#!/bin/bash
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
PKMODE="STREAM"
DEVFD="${DEVFD:-3}"
STDOUT="YES"
export TTY SPEED PKMODE DEVFD STDOUT HOST

ADDR="${ADDR:-${1}}"
ADDR="${ADDR:-0}"
ADDR="$((${ADDR} | (1 << 31)))"
ADDR=`printf %08x ${ADDR}`
ADDR="${ADDR: -8}"

LENGTH="${LENGTH:-${2}}"
LENGTH="${LENGTH:-0}"
LENGTH=`printf %06x $(( ${LENGTH} ))`
LENGTH="${LENGTH: -6}"
echo $ADDR $LENGTH
echo "1702${LENGTH}1603${ADDR}"|xxd -r -ps|./scripts/siocomm.sh |xxd -ps| tr -d '\n'
echo
