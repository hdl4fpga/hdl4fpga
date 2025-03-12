#!/bin/sh
echo -n "$2"|xxd -r -ps|socat - udp:"$1"
