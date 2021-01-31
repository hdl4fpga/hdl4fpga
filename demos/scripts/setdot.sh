#!/bin/sh
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"

./scritps/setack.sh

echo "\
1803\
17020000001602${BADDR}"|xxd -r -ps|./scritps/siocomms.sh
