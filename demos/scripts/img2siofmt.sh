#!/bin/sh
KIT="${KIT:-ULX3S}"
BADDR="${BADDR:-0}"

case ${KIT} in
"nuhs3adsp")
	PIXEL="${PIXEL:-rgb32}"
	WSIZE="${WSIZE:-32}"
	BSIZE="${BSIZE:-1024}"
	;;
"ULX3S")
	PIXEL="${PIXEL:-rgb565}"
	WSIZE="${WSIZE:-16}"
	BSIZE="${BSIZE:-1920}"
	;;
esac

PKTMD="${PKTMD:-PKT}"
WIDTH="${WIDTH:-800}"

if  [ "${PKTMD}" = "PKT" ] ; then
	POPT="-p"
fi 

echo Converting "${IMAGE}" to "${WIDTH}" pixel wide 1>&2
convert - -resize "${WIDTH}" -size "${WIDTH}" rgb:- |./bin/rgb8topixel -f ${PIXEL}|./bin/format -b "${BSIZE}" -w "${WSIZE}"|./bin/bundle -b "${BADDR}" "${POPT}"
