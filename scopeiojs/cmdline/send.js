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
const commjs  = require('./comm.js');

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

process.stdin.resume();
process.stdin.setEncoding('utf8');

var data = "";
process.stdin.on('data', function(chunk) {
	data += chunk;

	let i      = 0;
	let length = 0;
	console.log(data);
	while ((length+1) < data.length) {
		let step = (data.charCodeAt(i+1) + 3);
		console.log("step", step);
		if ((length+step) <= data.length) {
			if (length+step < 1024) {
				length += step;
			} else break;
		} else break;
	}
	if (length > 0) {
		commjs.send(data.slice(0, length));
		data = data.slice(length);
		if (data.length > 0) 
			console.log("length data left %s", data);
	}
});

process.stdin.on('end', function() {
});

