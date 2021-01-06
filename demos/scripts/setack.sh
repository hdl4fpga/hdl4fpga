#!/bin/sh
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
ACK="${1:-10}"

ACK=`printf %02x ${ACK}`
echo "00020000${ACK}"|xxd -r -ps|./scripts/send.sh
