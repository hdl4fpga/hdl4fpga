# Copyright (c) <2015> <Miguel Angel Sagreras>                                    #
#                                                                                 #
# Permission is hereby granted, free of charge, to any person obtaining a copy of #
# this software and associated documentation files (the "Software"), to deal in   #
# the Software without restriction, including without limitation the rights to    #
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   #
# of the Software, and to permit persons to whom the Software is furnished to do  #
# so, subject to the following conditions:                                        #
#                                                                                 #
# The above copyright notice and this permission notice shall be included in all  #
# copies or substantial portions of the Software.                                 #
#                                                                                 #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   #
# SOFTWARE.                                                                       #
#                                                                                 #

TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
PKMODE="STREAM"
DEVFD="${DEVFD:-3}"
STDOUT="YES"
export TTY SPEED PKMODE DEVFD STDOUT HOST

ADDR="${ADDR:-${1}}"
ADDR="${ADDR:-0}"
ADDR="$((${ADDR} & ~(1 << 31)))"
ADDR=`printf %08x ${ADDR}`
ADDR="${ADDR: -8}"

LENGTH="${LENGTH:-${#2}}"
LENGTH="${LENGTH:-0}"
LEN=`printf %02x $(( ${LENGTH}/2-1 ))`
LENGTH=`printf %06x 0x${LEN}`
DATA=`echo -n "18${LEN}${2}1702${LENGTH}1603${ADDR}"`
echo $ADDR':'$LENGTH ' : ' "${DATA}"
echo  "${DATA}"|xxd -r -ps|./scripts/siocomm.sh |xxd -ps| tr -d '\n'

