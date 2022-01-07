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
if [ ! -f "`which sudo 2> /dev/null`" ] ; then
	echo "sudo command is required to install nw-gyp globally and compile serialport"
	exit -1
fi

sudo npm -g install nw-gyp
npm install nw --nwjs_build_type=sdk
npm install serialport
npm_config_target=`npm view nw version`
npm_config_arch="x64"
npm_config_traget_arch="x64"
export npm_config_target npm_config_arch npm_config_traget_arch
npm_config_node_gyp=`which nw-gyp`
export npm_config_node_gyp

cd node_modules/\@serialport/bindings
nw-gyp rebuild --target=`npm view nw version` --arch=x64
cd -
