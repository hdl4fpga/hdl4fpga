#!/bin/sh
PIXEL="${PIXEL:-rgb32}"
BADDR="${BADDR:-0}"
BSIZE="${BSIZE:-1280}"
PKTMD="${PKTMD:-PKT}"
WIDTH="${WIDTH:-800}"

if  [ "${PKTMD}" = "PKT" ] ; then
	POPT="-p"
fi

echo Converting "${IMAGE}" to "${WIDTH}" pixel wide 1>&2
convert - -resize "${WIDTH}" -size "${WIDTH}" rgb:- |./bin/rgb8topixel -f ${PIXEL}|./bin/format -b "${BSIZE}"|./bin/bundle -b "${BADDR}" "${POPT}"
