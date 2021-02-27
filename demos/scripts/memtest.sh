#!/bin/bash
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
PKMODE="STREAM"
DEVFD="${DEVFD:-3}"
SETUART="NO"
DEBUGLOG="${DEBUGLOG:-debug.log}"
STDOUT="YES"
export TTY SPEED PKMODE DEVFD SETUART STDOUT

rm -f ${DEBUGLOG}

#coproc sio { ./scripts/siocomm.sh ; }
#{ echo -n "1602${ADDR}1702${LENGTH}"| xxd -r -ps ; } >&"${sio[1]}"
#{ while read -r data ; do echo ${data} ; done ; } <&"${sio[0]}" 

./scripts/setuart.sh

function lfsr16 ()
{
	local lfsr=${1}
	local bit

	bit=$(( (lfsr >> (16-16)) ^ (lfsr >> (16-14)) ^ (lfsr >> (16-13)) ^ (lfsr >> (16-11)) ))
	bit=$(( (bit <<  (16-1)) & ((1 << 16) - 1) ))
	lfsr=$(( (lfsr >> 1) | bit ));

	echo ${lfsr}

}

function lfsr24 ()
{
	local lfsr=${1}
	local bit

	bit=$(( (lfsr >> (24-24)) ^ (lfsr >> (24-23)) ^ (lfsr >> (24-21)) ^ (lfsr >> (24-20)) ))
	bit=$(( (bit <<  (24-1)) & ((1 << 24) -1) ))
	lfsr=$(( (lfsr >> 1) | bit ));

	echo ${lfsr}

}

function lfsr32 ()
{
	local lfsr=${1}
	local bit

	bit=$(( (lfsr >> (32-32)) ^ (lfsr >> (32-30)) ^ (lfsr >> (32-26)) ^ (lfsr >> (32-25)) ))
	bit=$(( (bit <<  (32-1)) & ((1 << 32) -1)))
	lfsr=$(( (lfsr >> 1) | bit ));

	echo ${lfsr}

}

function mem_read ()
{
	local ADDR=`printf %08x $(( (${1} & 0xffffff) | (1 << 31) ))`
	local LEN=`printf %06x ${2}`
	local SIODATA=`echo -n "1603${ADDR}1702${LEN}"|xxd -r -ps|./scripts/siocomm.sh ${DEBUG} 2>> ${DEBUGLOG}|xxd  -ps| tr -d '\n'`

	while [ "${SIODATA}" != "" ] ; do
		local RID=${SIODATA:0:2}
		local LEN=${SIODATA:2:2}
		local DATA=${SIODATA:4:$((2*${LEN}+2))}
		if [ "${RID}" == "ff" ] ; then
			break
		fi
		SIODATA=${SIODATA:$((2*${LEN}+2+4))}
	done
	if [ "${RID}" != "ff" ] ; then
		echo "No MEMORY DATA has been received"
		exit 1
	fi
	echo "${DATA}"
}

function mem_write ()
{
	local ADDR=`printf %08x $(( ${1} & 0xffffff ))`
	local LEN=`printf %06x ${2}`
	local DATA=`printf %04x ${3}`

	local SIODATA=`echo -n "1801${DATA}1603${ADDR}1702${LEN}"|xxd -r -ps|./scripts/siocomm.sh ${DEBUG} 2>> ${DEBUGLOG}|xxd -ps| tr -d '\n'`
}

ADDR=$(( (1 << 23) ))
LEN=0
LFSR=1
while true ; do
	echo -n "Address:0x`printf %06x ${ADDR}` LFSR:0x`printf %04x $LFSR`"
	if [ "${DEBUG}" != "" ] ; then echo "### Writing ###" 2>>${DEBUGLOG} 1>&2 ; fi
	mem_write "${ADDR}" "${LEN}" "${LFSR}"
	if [ "${DEBUG}" != "" ] ; then echo "### Reading ###" 2>>${DEBUGLOG} 1>&2 ; fi
		RDATA=`mem_read ${ADDR} ${LEN}`

	if [ `printf %04x $LFSR` != "${RDATA}" ] ; then
		echo "Mismacth RDATA:0x${RDATA}" 
		exit
	else
		echo " OK" 
	fi

	if [ ${ADDR} -eq  1 ] ; then
		break;
	fi

	ADDR=`lfsr24 ${ADDR}` #$(( ADDR + 1 ))
	LFSR=`lfsr16 ${LFSR}`
done

echo "Good job, NO MISMATCH"