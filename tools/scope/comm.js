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

// Asynchronous communication
//

const SerialPort = require('serialport')
const Readline   = require('@serialport/parser-readline'); 
const parser     = new Readline();

const baudRates  = [ 9600, 38400, 115200 ];

let uart;
let hostName;


let commOption;

function streamout (buffer) {

	function logwrite (buffer) {
		const buf = Buffer.alloc(1,buffer);
		console.log(buf.toString('hex'));
		uart.write(buf);
	}

	const esc = Buffer.alloc(1,0x5c);	// ASCII code for "\"
	const eos = Buffer.alloc(1,0x00);	// ASCII code for NUL

	for (i = 0; i < buffer.length; i++) {
		if (buffer[i] == esc[0] || buffer[i] == eos[0]) {
			logwrite(esc);
		}
		logwrite(buffer[i]);
	}
	logwrite(eos);
}

// TCP/IP communication
//

const dgram = require('dgram');
var udpsckt = dgram.createSocket('udp4');

function send(data) {

	console.log(commOption);
	switch (commOption) {
	case 'UART':
		var buffer = Buffer.from(data);
		streamout(buffer);
		break;
	case 'TCPIP':
		const ipport = 57001;
		console.log(getHost());
		var buffer = Buffer.alloc(data.length+2);
		for (i=0; i < data.length; i++)
			buffer[i] = data[i];

		buffer[i++] = 0xff;
		buffer[i++] = 0xff;
		udpsckt.send(buffer, ipport, hostName, function(err, bytes) {
			if (err) throw err;
			console.log('UDP message has been sent');
		});
		break;
	}
}

function createUART (uartName, options) {
	if (typeof uart !== 'undefined')
		uart.close();
	console.log(uartName);
	console.log(options);
	uart = new SerialPort(uartName, options);
}

function listUART () {
	return SerialPort.list();
}

function getHost(name) {
	return hostName;
}

function setHost(name) {
	hostName = name;
}

function setCommOption(option) {
	commOption = option;
}

function getCommOption(option) {
	return commOption;
}
