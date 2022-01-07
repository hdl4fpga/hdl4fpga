#!/bin/sh
SCRIPTDIR=/mt/lattice/diamond/3.8_x64/synpbase/bin
REPLACER=./change-inplace-sh-to-bash.sh
#REPLACER=ls
find $SCRIPTDIR -type f -exec $REPLACER {} \;
