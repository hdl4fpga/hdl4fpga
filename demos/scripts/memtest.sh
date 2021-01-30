#!/bin/bash
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
PKMODE="STREAM"
DEVFD="${DEVFD:-3}"
SETUART="NO"
DEBUGLOG="${DEBUGLOG:-debug.log}"
export TTY SPEED PKMODE DEVFD SETUART

rm -f ${DEBUGLOG}

#coproc sio { ./scripts/send.sh ; }
#{ echo -n "1602${ADDR}1702${LENGTH}"| xxd -r -ps ; } >&"${sio[1]}"
#{ while read -r data ; do echo ${data} ; done ; } <&"${sio[0]}" 

./scripts/setuart.sh

function lfsr ()
{
	local lfsr=${1}
	local bit

	# feedback polynomial: x^16 + x^14 + x^13 + x^11 + 1
	bit=$(( (lfsr >> (16-16)) ^ (lfsr >> (16-14)) ^ (lfsr >> (16-13)) ^ (lfsr >> (16-11)) ))
	bit=$(( (bit <<  15) & 0xffff ))
	lfsr=$(( (lfsr >> 1) | bit ));

	echo ${lfsr}

}

function mem_read ()
{
	local ADDR=`printf %06x $(( ${1} | (1 << 23) ))`
	local LEN=`printf %06x ${2}`
	local SIODATA=`echo -n "1602${ADDR}1702${LEN}"|xxd -r -ps|./scripts/send.sh 2>> ${DEBUGLOG}`

	while [ "${SIODATA}" != "" ] ; do
		local RID=${SIODATA:0:2}
		local LEN=${SIODATA:2:2}
		local DATA=${SIODATA:4:$((2*${LEN}+2))}
		if [ "${RID}" == "ff" ] ; then
			break
		fi
		SIODATA=${SIODATA:$((2*${LEN}+2+4))}
	done
	echo "${DATA}"
}

function mem_write ()
{
	local ADDR=`printf %06x ${1}`
	local LEN=`printf %06x ${2}`
	local DATA=`printf %04x ${3}`

	local SIODATA=`echo -n "1801${DATA}1602${ADDR}1702${LEN}"|xxd -r -ps|./scripts/send.sh 2>> ${DEBUGLOG}`
}

ADDR=0
LEN=0x00000000
LFSR=0x0001
while [ ${ADDR} -lt 65535 ] ; do
	echo "Address:`printf %06x ${ADDR}` LFSR:`printf %04x $LFSR`"
	echo "### Writing ###" 2>>${DEBUGLOG} 1>&2
	mem_write "${ADDR}" "${LEN}" "${LFSR}"
	echo "### Reading ###" 2>>${DEBUGLOG} 1>&2
	RDATA=`mem_read ${ADDR} ${LEN}`

	if [ `printf %04x $LFSR` != "${RDATA}" ] ; then
		echo "Mismacth LFSR:`printf %04x $LFSR` RDATA:${RDATA}" 
		exit
	fi

	ADDR=$(( ADDR + 1 ))
	LFSR=`lfsr ${LFSR}`
done
