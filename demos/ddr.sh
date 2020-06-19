#!/bin/bash
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
PROG="ujprog ../ULX3S/diamond/graphic/demos_graphic.bit"

# Load library
source ./lib.sh

program_device
set_tty

cat < $TTY > dump. out &

XADDR=`printf %06x ${ADDR}`
echo "1602${XADDR}"|xxd -r -ps|./bin/stream|cat > "${TTY}"
echo "1802${XDATA}"|xxd -r -ps|./bin/stream|cat > "${TTY}"
echo "1702${XSIZE}"|xxd -r -ps|./bin/stream|cat > "${TTY}"
echo "1902${XADDR}"|xxd -r -ps|./bin/stream|cat > "${TTY}"
echo "2002${XSIZE}"|xxd -r -ps|./bin/stream|cat > "${TTY}"
