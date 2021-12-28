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
#$echo -n $ADDR ' : '
data=`echo "1702${LENGTH}1603${ADDR}"|xxd -r -ps|./scripts/siocomm.sh |xxd -ps| tr -d '\n'`
data=`echo $data|cut -b 21-`
while [ "$data" != "" ] ; do
	len=`echo -n $data|cut -b 1-2`
	len=`printf %d $(( 0x${len} ))`
	data=`echo -n $data|cut -b 3-`
	len=`expr 2 \* \( $len \+ 1 \)`
	echo -n $data|cut -b 1-$len|tr -d '\n'
	len=`expr  $len \+ 3 `
	data=`echo -n $data|cut -b $len-`
done
echo
