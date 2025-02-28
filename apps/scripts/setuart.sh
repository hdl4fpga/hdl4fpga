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

if [ ! -c "${TTY}" ] ; then
	echo Serial port "${TTY}" not found 1>&2
	exit -1
fi

echo Setting serial speed ${SPEED} to port "${TTY}" 1>&2
stty -F  "${TTY}" sane 1>&2
stty -F  "${TTY}" "${SPEED}" cs8 raw -echo -cstopb -parenb -onlcr -ocrnl -onlcr -ofdel -onlret -opost 1>&2

