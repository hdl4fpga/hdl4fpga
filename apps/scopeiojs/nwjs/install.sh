#!/bin/sh
# Copyright (c) 2015 Miguel Angel Sagreras                                       #
#                                                                                #
# Permission is hereby granted, free of charge, to any person obtaining a copy   #
# of this software and associated documentation files (the "Software"), to deal  #
# in the Software without restriction, including without limitation the rights   #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      #
# copies of the Software, and to permit persons to whom the Software is          #
# furnished to do so, subject to the following conditions:                       #
#                                                                                #
# The above copyright notice and this permission notice shall be included in all #
# copies or substantial portions of the Software.                                #
#                                                                                #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  #
# SOFTWARE.                                                                      #
#                                                                                #

ln -fs ../html
ln -fs ../srcjs
npm install nw-gyp
sed -i 's/var config = process.config/var config = JSON.parse(JSON.stringify(process.config))/' ./node_modules/nw-gyp/lib/configure.js # See https://github.com/nwjs/nw-gyp/issues/155
npm install --save-dev nw@sdk
npm install usb
npm install serialport
export npm_config_target=`npm view nw version`
export npm_config_arch="x64"
export npm_config_traget_arch="x64"
export npm_config_node_gyp=`npx which nw-gyp`
rm -rf ./bin
mkdir bin
if which python2 > /dev/null 2>&1 ; then
	ln -s `which python2` bin/python
	ln -s `which python2-config` bin/python-config
else
	echo "python2 not found, it is required to compile serialport and usb"
	exit 1
fi
PATH=`pwd`/bin:$PATH 
cd node_modules/\@serialport/bindings-cpp
PATH=$PATH npx nw-gyp rebuild --target=`npm view nw version` --arch=x64
cd -
cd node_modules/usb
PATH=$PATH npx nw-gyp rebuild --target==`npm view nw version` --arch=x64
cd -
rm -r ./bin



