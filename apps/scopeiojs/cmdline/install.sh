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
