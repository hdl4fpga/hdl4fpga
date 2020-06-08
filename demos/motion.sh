#!/bin/bash
TTY="${TTY:-/dev/ttyUSB0}"
SPEED=3000000
MSIZE=`expr 32 \* 1024 \* 1024`
WIDTH=800
HEIGHT=600
FSIZE=`expr 2 \* ${WIDTH} \* ${HEIGHT}`
FRAMES=`expr \( ${MSIZE} - ${FSIZE} - 1 \) \/ ${FSIZE}`
PROG="ujprog ../ULX3S/diamond/graphic/demos_graphic.bit"

if [ "${MOTION}" == "" ] ; then
	echo "MOTION variable unset" >&2
	exit -1;
fi

if [ ! -t `which ffmpeg`] ; then
	echo "ffmpeg required" >&2
	exit -1;
fi

mkdir -p frames
ffmpeg -i "${MOTION}" -f image2 frames/image-%07d.jpg

N=0
for file in frames/image-*.jpg ; do
	N=`expr ${N} + 1`
done
M=`expr ${N} / ${FRAMES}`

N=0
ADDR=0
FRAMES=0
for file in frames/image-*.jpg ; do
	if [ `expr ${N} % ${M}` -eq 0 ] ; then
		convert ${file} -gravity center -crop 1280x960+0+0 -resize ${WIDTH}x${HEIGHT} output.jpg
		if [ "$N" -ne 0 ] ; then
			unset PROG
		fi
		TTY="${TTY}" SPEED="${SPEED}" BSIZE="2048" BADDR="0x${BADDR}" PROG="${PROG}" BLANK="NO" IMAGE=output.jpg sh upload-image.sh

		ADDR=`expr ${ADDR} + ${FSIZE} \/ 2`
		BADDR=`printf %06x ${ADDR}`
		echo "1902${BADDR}"|xxd -r -ps|./bin/stream|cat > "${TTY}"
		FRAMES=`expr ${FRAMES} + 1`
	fi
	N=`expr ${N} + 1`
done

# ######### #
# Animation #
# ######### #

while true ; do 
	N=0
	ADDR=0
	while [ "${N}" -lt "$FRAMES" ] ; do
		BADDR=`printf %06x ${ADDR}`
		echo "1902${BADDR}"|xxd -r -ps|./bin/stream|cat > "${TTY}"
		ADDR=`expr ${ADDR} + ${FSIZE} \/ 2`
		N=`expr $N + 1`
		sleep 0.075
	done
done
