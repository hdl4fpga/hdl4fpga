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

npm install bufferutil
npm install utf-8-validate
npm install socket.io
npm install serialport
npm install commander
npm install usb
rm -rf nodesrv.js comm.js
ln ../srcjs/nodesrv.js 
ln ../srcjs/comm.js 
