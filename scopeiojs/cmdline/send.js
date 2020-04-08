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

const program = require('commander');
const sscanf  = require('scanf').sscanf;
const commjs  = require('./comm.js');

program
	.option('-l, --link <type>', 'ip       | serial', 'ip')
	.requiredOption('-n, --name <name>',  'hostname | ip address | serial port')
	.option('-r, --rid   <id>', 'number')
	.requiredOption('-t, --type <value>', 'Data type', 'hex')
	.requiredOption('-d, --data <value>', 'Data to be sent is required')
	.parse(process.argv);

switch(program.type) {
case 'hex' :
	var data   = program.data.trim().toUpperCase().replace(/\s/g, '');
	if (typeof program.rid === 'undefined')
		var base = 1;
	 else
		var base = 2;
	var buffer = new Uint8Array(data.length/2+base);

	buffer[base-1] = (data.length-(data.length % 2))/2+base-3;
	for (i = 0; i < data.length-(data.length % 2); i += 2) {
		buffer[i/2+base] = 0;
		for (j = 0; j < 2; j++) {
			buffer[i/2+base] *= 16;
			if ('0'.charCodeAt(0) <= data.charCodeAt(i+j) && data.charCodeAt(i+j) <= '9'.charCodeAt(0)) 
				buffer[i/2+base] += data.charCodeAt(i+j) - '0'.charCodeAt(0);
			else if ('A'.charCodeAt(0) <= data.charCodeAt(i+j) && data.charCodeAt(i+j) <= 'F'.charCodeAt(0)) 
				buffer[i/2+base] += (data.charCodeAt(i+j) - 'A'.charCodeAt(0))+10;
			else {
				throw ("wrong");
			}
		}
	}
	if (typeof program.rid === 'undefined') {
		program.rid = buffer[1];
		buffer[1] = buffer[0];
	}
	buffer[0] = parseInt(program.rid);
	break;
case 'string':
}
console.log(data);

switch(program.link) {
case 'serial':
	commjs.setCommOption('UART');
	break;
case 'ip':
default:
	commjs.setCommOption('TCPIP');
	break;
}

switch (commjs.getCommOption()) {
case 'UART':
	commjs.createUART(program.name, "115200");
	break;
case 'TCPIP':
	commjs.setHost(hostName);
	break;
}

commjs.send(buffer);
