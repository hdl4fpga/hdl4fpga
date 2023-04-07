#!/bin/bash
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
PKMODE="STREAM"
DEVFD="${DEVFD:-3}"
STDOUT="YES"
export TTY SPEED PKMODE DEVFD STDOUT HOST

ADDR="${ADDR:-${1}}"
ADDR="${ADDR:-0}"
ADDR="$((${ADDR} & ~(1 << 31)))"
ADDR=`printf %08x ${ADDR}`
ADDR="${ADDR: -8}"

LENGTH="${LENGTH:-${#2}}"
LENGTH="${LENGTH:-0}"
LEN=`printf %02x $(( ${LENGTH}/2-1 ))`
LENGTH=`printf %06x $(( ${LEN} ))`
LENGTH="${LENGTH: -6}"
DATA=`echo -n "18${LEN}${2}1702${LENGTH}1603${ADDR}"`
echo $ADDR':'$LENGTH ' : ' "${DATA}"
echo "${DATA}"|xxd -r -ps|./scripts/siocomm.sh |xxd -ps| tr -d '\n'
