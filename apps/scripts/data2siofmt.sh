#!/bin/sh
KIT="${KIT:-ULX3S}"
BADDR="${BADDR:-0}"
BSIZE="${BSIZE:-4096}"
PKTMD="${PKTMD:-PKT}"

if  [ "${PKTMD}" = "PKT" ] ; then
	POPT="-p"
fi

./bin/format -b "${BSIZE}" |./bin/bundle -b "${BADDR}" "${POPT}"
