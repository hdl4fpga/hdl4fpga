#!/bin/sh
WIDTH="${WIDTH:-800}"
SPEED="${SPEED:-3000000}"
BLANK="${BLANK:-YES}"
BADDR="${BADDR:-0x0}"

if [ "${KIT}" = "ulx3s" ] ; then
	PIXEL="${PIXEL:-rgb565}"
	WSIZE="${WSIZE:-16}"
	BSIZE="${BSIZE:-256}"
else if  [ "${KIT}" = "nuhs3adsp" ] ; then
	PIXEL="${PIXEL:-rgb32}"
	WSIZE="${WSIZE:-32}"
	BSIZE="${BSIZE:-256}"
else
	PIXEL="${PIXEL:-rgb565}"
	WSIZE="${WSIZE:-16}"
	BSIZE="${BSIZE:-256}"
fi; fi 

echo make 1>&2
make all 1>&2

convert_image ()
{
	convert - -resize "${WIDTH}" -size "${WIDTH}" rgb:- |./bin/rgb8topixel -f ${PIXEL}|./bin/format -b "${BSIZE}" -w "${WSIZE}"|./bin/bundle -b "${BADDR}" -p 
}

echo Converting "${IMAGE}" to "${WIDTH}" pixel wide and sending it to "${DESTINATION}" 1>&2
convert_image
