#!/bin/bash
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
PKMODE="STREAM"
DEVFD="${DEVFD:-1}"
export TTY SPEED PKMODE DEVFD

#coproc sio { ./scripts/send.sh ; }
#{ echo -n "1602${ADDR}1702${LENGTH}"| xxd -r -ps ; } >&"${sio[1]}"
#{ while read -r data ; do echo ${data} ; done ; } <&"${sio[0]}" 

./scripts/setuart.sh

function mem_read ()
{
	ADDR=`printf %06x $((${1} | (1 << 23)))`
	LEN=`printf %06x ${2}`

	SIODATA=`echo -n "1602${ADDR}1702${LEN}"|xxd -r -ps|3<>${TTY} ./bin/sendbyahdlc`

	while [ "${SIODATA}" != "" ] ; do
		RID=${SIODATA:0:2}
		LEN=${SIODATA:2:2}
		DATA=${SIODATA:4:$((2*${LEN}+2))}
		if [ "${RID}" == "ff" ] ; then
			break
		fi
		SIODATA=${SIODATA:$((2*${LEN}+2+4))}
	done
	echo "${DATA:2:2}${DATA:0:2}"
}

function mem_write ()
{
	ADDR=`printf %06x ${1}`
	LEN=`printf %06x ${2}`
	DATA=`printf %04x ${3}`

	SIODATA=`echo -n "1602${ADDR}1702${LEN}18ff${DATA}"|xxd -r -ps|3<>${TTY} ./bin/sendbyahdlc`
}

ADDR=0x00000000
LEN=0x00000000
WDATA=`printf %04x ${1}`

mem_write "${ADDR}" "${LEN}" "${1}"
RDATA=`mem_read ${ADDR} ${LEN}`

if [ "${WDATA}" != "${RDATA}" ] ; then
	echo "Mismacth WDATA:${WDATA}" RDATA:"${RDATA}" 1>&2
fi
