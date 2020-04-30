
//                                                                            //
// Author(s):                                                                 //
//   Miguel Angel Sagreras                                                    //
//                                                                            //
// Copyright (C) 2015                                                         //
//    Miguel Angel Sagreras                                                   //
//                                                                            //
// This source file may be used and distributed without restriction provided  //
// that this copyright statement is not removed from the file and that any    //
// derivative work contains  the original copyright notice and the associated //
// disclaimer.                                                                //
//                                                                            //
// This source file is free software; you can redistribute it and/or modify   //
// it under the terms of the GNU General Public License as published by the   //
// Free Software Foundation, either version 3 of the License, or (at your     //
// option) any later version.                                                 //
//                                                                            //
// This source is distributed in the hope that it will be useful, but WITHOUT //
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      //
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   //
// more details at http://www.gnu.org/licenses/.                              //
//                                                                            //

const fs      = require('fs');
const commjs  = require('./comm.js');
const program = require('commander');

program
	.requiredOption('-l, --link <type>', 'udp      | serial')
	.requiredOption('-n, --name <name>', 'hostname | ip address | serial port')
	.parse(process.argv);

switch(program.link) {
case 'serial':
	commjs.setCommOption('UART');
	commjs.createUART(program.name, "115200");
	break;
case 'ip':
	commjs.setCommOption('TCPIP');
	commjs.setHost(program.name);
	break;
default:
	program.help();
	break;
}

var fb = fs.readFileSync('image.rgb');

var memaddr = new Uint8Array(2+3);
var memlen  = new Uint8Array(2+3);
var memdata = new Uint8Array(2+256)

var comp;
for (var i = 0; fb.byteLength-i >= (3*256/4); i += 3*256/4) {

	var addr = (4*i/3) >> 2;

	memaddr[0] = 0x16;
	memaddr[1] = 0x02;
	memaddr[2] = (addr >> 16) & 0xff;
	memaddr[3] = (addr >>  8) & 0xff;
	memaddr[4] = (addr >>  0) & 0xff;

	memlen[0]  = 0x17;
	memlen[1]  = 0x02;
	memlen[2]  = 0x00;
	memlen[3]  = 0x00;
	memlen[4]  = 0x3f;

	memdata[0] = 0x18;
	memdata[1] = 0xff;

	for (var j = 0 ; j < 256/4; j++) {
		memdata[4*j+0] = fb[3*j+0];
		memdata[4*j+1] = fb[3*j+1];
		memdata[4*j+2] = fb[3*j+2];
		memdata[4*j+3] = 0x00;
	}

	commjs.send(memdata);
	commjs.send(memaddr);
	return 0;
//	commjs.send(memlen);

}
