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

var commOption;

function setCommOption(option) {
	commOption = option;
}

function getCommOption() {
	return commOption;
}

var uart;

const { SerialPort } = require('serialport');
const Readline = SerialPort.ReadlineParser;
try{
} catch(error) {
}

const baudRates  = [ 9600, 38400, 115200 ];

function toHex(buffer)
{
	let len = (typeof buffer.length === 'undefined') ? buffer.byteLength : buffer.length;
	let str = "";

	for (var i=0; i < len; i++) 
		if (buffer[i] < 16) 
			str = str + ' ' + '0' + Number(buffer[i]).toString('16');
		else
			str = str + ' ' + Number(buffer[i]).toString('16');
	return str;
}

function streamout (data) {

	const esc = 0x5c;
	const eod = 0x00;

	function bufferSize (data) {
		var size = 0;
		for (var i = 0; i < data.length; i++) {
			switch (data[i]) {
			case esc:
			case eod:
				size++;
			default:
				size++;
			}
		}
		size++;	// end of data;
		return size;
	}

	var buffer = new Uint8Array(bufferSize(data)+2);
	var str = '';

	var j = 0;
	buffer[j++] = eod;
	buffer[j++] = eod;
	for (var i = 0; i < data.length; i++) {
		switch (data[i]) {
		case esc:
		case eod:
			buffer[j++] = esc;

		default:
			buffer[j++] = data.charCodeAt(i);
		}
	}
	buffer[j++] = eod;
	uart.write(buffer);
	return toHex(buffer);
}

function listUART () {
	return SerialPort.list();
}

function createUART (args) {
	if (typeof uart !== 'undefined')
		if (uart.err === false) {
			console.log("closed : " + uart.path);
			uart.close();
		}

	let uartError;
	uart = new SerialPort(args, function(err) {
		uart.err = false;
		if (err) {
			console.log(err);
			uart.err = true;
		}
	});
	return uart;
}

// UDP communication
//

var hostName;

function getHost() {
	return hostName;
}

function setHost(name) {
	hostName = name;
}

const dgram = require('dgram');
var udpsckt = dgram.createSocket('udp4');

function send(data) {
	var i;

	switch (commOption) {
	case 'UART':
		console.log(commOption + streamout(data));
		break;
	case 'TCPIP':
		const ipport = 57001;
		var buffer   = new Uint8Array(data.length+2);
	
		if (data instanceof Uint8Array) {
			for (i=0; i < data.length; i++)
				buffer[i] = data[i];
		} else {
			for (i=0; i < data.length; i++)
				buffer[i] = data.charCodeAt(i);
		}

		buffer[i++] = 0xff;
		buffer[i++] = 0xff;
		udpsckt.send(buffer, ipport, hostName, function(err, bytes) {
			if (err)
				throw(err);
			else {
//				udpsckt.close();
				console.log('UDP :' + toHex(buffer));
			}
		});
		break;
	case 'USB':
		break;
	}
}

// USB
const usb = require('usb');
var  usbdev;

function openUSB() {
	if (typeof usbdev !== 'undefined') {
		usbdev = usb.findByIds(0x1234, 0xabcd);
	}

	if (usbdev) {
		usbdev.open();
		console.log(usbdev.interface(0));
		console.log(usbdev);
	}
	return usbdev;
}

function usbSend (data) {
	var fcs = ~pppfcs16(PPPINITFCS16, data, len);

	var buffer = [];
	var ptr = 0;

	buffer[ptr++] = 0x7e;
	for (int i = 0; i < len+sizeof(fcs); i++) {
		char c;

		if (i < len) {
			c = data[i];
		} else {
			c = ((char *) &fcs)[i-len];
		}

		if (c == 0x7e) {
			buffer[ptr++] = 0x7d;
			c ^= 0x20;
		} else if(c == 0x7d) {
			buffer[ptr++] = 0x7d;
			c ^= 0x20;
		}
		buffer[ptr++] = c;
	}
	buffer[ptr++] = 0x7e;

// Read data from the USB device
inEndpoint.transferIn(64, (error, data) => {
  if (error) {
    console.error('Error reading data:', error);
  } else {
    console.log('Data received:', data);
  }
});

// Write data to the USB device
const dataToWrite = Buffer.from('Hello, USB Device!');
outEndpoint.transferOut(dataToWrite, (error) => {
  if (error) {
    console.error('Error writing data:', error);
  } else {
    console.log('Data sent successfully.');
  }
});

// Handle errors and clean up when done
process.on('SIGINT', () => {
  inEndpoint.stop();
  outEndpoint.stop();
  interface.release(() => {
    device.close();
    process.exit();
  });
});

console.log('Listening for data. Press Ctrl+C to exit.');

	int result;
	int transferred;
	while ((result = libusb_bulk_transfer(usbdev, usbendp & ~0x80, buffer, ptr-buffer, &transferred, 0))!=0) {
		if (result == LIBUSB_ERROR_PIPE) {
			libusb_clear_halt(usbdev, usbendp);
			fprintf(stderr, "WRITING PIPE ERROR\n");
			abort();
		} else {
			fprintf(stderr, "Error in bulk transfer. Error code: %d\n", result);
			perror ("sending packet");
			abort();
		}
	}
	pkt_sent++;
}


function close() {
	switch (commOption) {
	case 'UART':
		if (typeof uart !== 'undefined')
			if (uart.err === false) {
				console.log("closed : " + uart.path);
				uart.close();
			}

		break;
	case 'TCPIP':
		udpsckt.close();
		break;
	}
}

try {
exports.listUART      = listUART;
exports.createUART    = createUART;
exports.setCommOption = setCommOption;
exports.getCommOption = getCommOption;
exports.getHost       = getHost;
exports.setHost       = setHost;
exports.send          = send;
exports.close         = close;
exports.openUSB       = openUSB;
}
catch(e) {
}

