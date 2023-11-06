#!/bin/sh
#                                                                           
# Author(s):                                                                
#   Miguel Angel Sagreras                                                   
#                                                                           
# Copyright (C) 2015                                                        
#    Miguel Angel Sagreras                                                  
#                                                                           
# This source file may be used and distributed without restriction provided 
# that this copyright statement is not removed from the file and that any   
# derivative work contains  the original copyright notice and the associated
# disclaimer.                                                               
#                                                                           
# This source file is free software; you can redistribute it and/or modify  
# it under the terms of the GNU General Public License as published by the  
# Free Software Foundation, either version 3 of the License, or (at your    
# option) any later version.                                                
#                                                                           
# This source is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or     
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for  
# more details at http://www.gnu.org/licenses/.                             

ln -fs ../html
ln -fs ../srcjs
npm install nw-gyp
sed -i 's/var config = process.config || {}/var config = JSON.parse(JSON.stringify(process.config)) || {}/' ./node_modules/nw-gyp/lib/configure.js # See https://github.com/nwjs/nw-gyp/issues/155
npm install nw --nwjs_build_type=sdk
npm install usb
npm install serialport
export npm_config_target=`npm view nw version`
export npm_config_arch="x64"
export npm_config_traget_arch="x64"
export npm_config_node_gyp=`npx which nw-gyp`
rm -rf ./bin
mkdir bin
if which python2 > /dev/null; then
	ln -s `which python2` bin/python
	ln -s `which python2-config` bin/python-config
else
	exit 0
fi
PATH=`pwd`/bin:$PATH 
cd node_modules/\@serialport/bindings-cpp
PATH=$PATH npx nw-gyp rebuild --target=`npm view nw version` --arch=x64
cd -
cd node_modules/usb
PATH=$PATH npx nw-gyp rebuild --target==`npm view nw version` --arch=x64
cd -
rm -r ./bin