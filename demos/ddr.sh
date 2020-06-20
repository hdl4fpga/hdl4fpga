#!/bin/bash
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-115200}"
PROG="ujprog ../ULX3S/diamond/ddr/demos_ddr.bit"
WSIZ="${WSIZE:-2}"
ADDR="${ADDR:-0x000000}"
DATA="\
123456789abcdef123456789abcdef12\
23456789abcdef123456789abcdef123\
3456789abcdef123456789abcdef1234\
456789abcdef123456789abcdef12345\
56789abcdef123456789abcdef123456\
6789abcdef123456789abcdef1234567\
789abcdef123456789abcdef12345678\
89abcdef123456789abcdef123456789\
9abcdef123456789abcdef123456789a\
abcdef123456789abcdef123456789ab\
bcdef123456789abcdef123456789abc\
cdef123456789abcdef123456789abcd\
def123456789abcdef123456789abcde\
ef123456789abcdef123456789abcdef\
f123456789abcdef123456789abcdef1\
123456789abcdef123456789abcdef12"

# Load library
source ./lib.sh

#program_device
set_tty

#cat < $TTY > dump.out &
SIZE=${#DATA}
SIZE=`printf "%d" ${SIZE}`
SIZE=`expr ${SIZE} \/ ${WSIZ} \/ 2 \- 1`
SIZE=`printf "%06x" ${SIZE}`

LEN=${#DATA}
LEN=`printf "%d" ${LEN}`
LEN=`expr ${LEN} \/ 2 \- 1`
LEN=`printf "%02x" ${LEN}`

ADDR=`printf "%06x" ${ADDR}`
echo "Adress : 0x${ADDR}, Length : 0x${LEN}, DMA Length : 0x${SIZE}"
#echo "1602${ADDR}18${LEN}${DATA}1702${SIZE}"|xxd -r -ps|tee pp|./bin/stream|cat > "${TTY}"
echo "1902${ADDR}2002${SIZE}"|xxd -r -ps|tee pp1|./bin/stream|cat > "${TTY}"
