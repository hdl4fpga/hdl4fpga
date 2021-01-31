#!/bin/sh
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"

BADDR=${BADDR:-`printf %06x ${1}`}
BADDR=${BADDR: -6}
echo "1902${BADDR}"|xxd -r -ps|./scripts/siocomms.sh
