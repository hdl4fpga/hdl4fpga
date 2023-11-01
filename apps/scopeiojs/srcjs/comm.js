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

const fcstab = [
   0x0000, 0x1189, 0x2312, 0x329b, 0x4624, 0x57ad, 0x6536, 0x74bf,
   0x8c48, 0x9dc1, 0xaf5a, 0xbed3, 0xca6c, 0xdbe5, 0xe97e, 0xf8f7,
   0x1081, 0x0108, 0x3393, 0x221a, 0x56a5, 0x472c, 0x75b7, 0x643e,
   0x9cc9, 0x8d40, 0xbfdb, 0xae52, 0xdaed, 0xcb64, 0xf9ff, 0xe876,
   0x2102, 0x308b, 0x0210, 0x1399, 0x6726, 0x76af, 0x4434, 0x55bd,
   0xad4a, 0xbcc3, 0x8e58, 0x9fd1, 0xeb6e, 0xfae7, 0xc87c, 0xd9f5,
   0x3183, 0x200a, 0x1291, 0x0318, 0x77a7, 0x662e, 0x54b5, 0x453c,
   0xbdcb, 0xac42, 0x9ed9, 0x8f50, 0xfbef, 0xea66, 0xd8fd, 0xc974,
   0x4204, 0x538d, 0x6116, 0x709f, 0x0420, 0x15a9, 0x2732, 0x36bb,
   0xce4c, 0xdfc5, 0xed5e, 0xfcd7, 0x8868, 0x99e1, 0xab7a, 0xbaf3,
   0x5285, 0x430c, 0x7197, 0x601e, 0x14a1, 0x0528, 0x37b3, 0x263a,
   0xdecd, 0xcf44, 0xfddf, 0xec56, 0x98e9, 0x8960, 0xbbfb, 0xaa72,
   0x6306, 0x728f, 0x4014, 0x519d, 0x2522, 0x34ab, 0x0630, 0x17b9,
   0xef4e, 0xfec7, 0xcc5c, 0xddd5, 0xa96a, 0xb8e3, 0x8a78, 0x9bf1,
   0x7387, 0x620e, 0x5095, 0x411c, 0x35a3, 0x242a, 0x16b1, 0x0738,
   0xffcf, 0xee46, 0xdcdd, 0xcd54, 0xb9eb, 0xa862, 0x9af9, 0x8b70,
   0x8408, 0x9581, 0xa71a, 0xb693, 0xc22c, 0xd3a5, 0xe13e, 0xf0b7,
   0x0840, 0x19c9, 0x2b52, 0x3adb, 0x4e64, 0x5fed, 0x6d76, 0x7cff,
   0x9489, 0x8500, 0xb79b, 0xa612, 0xd2ad, 0xc324, 0xf1bf, 0xe036,
   0x18c1, 0x0948, 0x3bd3, 0x2a5a, 0x5ee5, 0x4f6c, 0x7df7, 0x6c7e,
   0xa50a, 0xb483, 0x8618, 0x9791, 0xe32e, 0xf2a7, 0xc03c, 0xd1b5,
   0x2942, 0x38cb, 0x0a50, 0x1bd9, 0x6f66, 0x7eef, 0x4c74, 0x5dfd,
   0xb58b, 0xa402, 0x9699, 0x8710, 0xf3af, 0xe226, 0xd0bd, 0xc134,
   0x39c3, 0x284a, 0x1ad1, 0x0b58, 0x7fe7, 0x6e6e, 0x5cf5, 0x4d7c,
   0xc60c, 0xd785, 0xe51e, 0xf497, 0x8028, 0x91a1, 0xa33a, 0xb2b3,
   0x4a44, 0x5bcd, 0x6956, 0x78df, 0x0c60, 0x1de9, 0x2f72, 0x3efb,
   0xd68d, 0xc704, 0xf59f, 0xe416, 0x90a9, 0x8120, 0xb3bb, 0xa232,
   0x5ac5, 0x4b4c, 0x79d7, 0x685e, 0x1ce1, 0x0d68, 0x3ff3, 0x2e7a,
   0xe70e, 0xf687, 0xc41c, 0xd595, 0xa12a, 0xb0a3, 0x8238, 0x93b1,
   0x6b46, 0x7acf, 0x4854, 0x59dd, 0x2d62, 0x3ceb, 0x0e70, 0x1ff9,
   0xf78f, 0xe606, 0xd49d, 0xc514, 0xb1ab, 0xa022, 0x92b9, 0x8330,
   0x7bc7, 0x6a4e, 0x58d5, 0x495c, 0x3de3, 0x2c6a, 0x1ef1, 0x0f78 ];

const PPPINITFCS16 =  0xffff; /* Initial FCS value */
const PPPGOODFCS16 =  0xf0b8; /* Good final FCS value */

function pppfcs16(fcs, data) {
	for (i = 0; i < data.length; i++) {
        fcs = (fcs >> 8) ^ fcstab[(fcs ^ data[i]) & 0xff];
	}

    return fcs;
}

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

// USB
const usb = require('usb');
var usbdev;

function openUSB() {
	if (typeof usbdev === 'undefined') {
		usbdev = usb.findByIds(0x1234, 0xabcd);
	}

		console.log('usb');
	if (usbdev) {
		console.log('usb open');
		usbdev.open();
		usbdev.interface(0).claim();
		console.log(usbdev.interface(0));
		console.log(usbdev);
	}
	return usbdev;
}

function usbSend (data) {
	var fcs = (~pppfcs16(PPPINITFCS16, data)) & 0xffff;

	var buffer = [];
	var ptr = 0;

	buffer[ptr++] = 0x7e;
	for (i = 0; i < data.length+16/8; i++) {
		var c;

		if (i < data.length) {
			c = data[i];
		} else {
			c = (((i-data.length) & 0x01) ? (fcs >> 0x08) : fcs) & 0xff;
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

	// Write data to the USB device
	console.log(toHex(buffer));
	console.log(usbdev.interface(0).endpoint(0x01).transfer(Buffer.from(buffer), (error) => {
		if (error) {
			console.error('Error writing data:', error);
		} else {
			// console.log('Data sent successfully.');
		}
	}));
}

// Read data from the USB device
// usbdev.interface(0).transferIn(64, (error, data) => {
	// if (error) {
		// console.error('Error reading data:', error);
	// } else {
		// console.log('Data received:', data);
	// }
// });

// Handle errors and clean up when done
// process.on('SIGINT', () => {
	// inEndpoint.stop();
	// outEndpoint.stop();
	// interface.release(() => {
		// device.close();
		// process.exit();
	// });
// });


	// int result;
	// int transferred;
	// while ((result = libusb_bulk_transfer(usbdev, usbendp & ~0x80, buffer, ptr-buffer, &transferred, 0))!=0) {
		// if (result == LIBUSB_ERROR_PIPE) {
			// libusb_clear_halt(usbdev, usbendp);
			// fprintf(stderr, "WRITING PIPE ERROR\n");
			// abort();
		// } else {
			// fprintf(stderr, "Error in bulk transfer. Error code: %d\n", result);
			// perror ("sending packet");
			// abort();
		// }
	// }
	// pkt_sent++;


var ack = 0x00;
function send(data) {
	var i;

	switch (commOption) {
	case 'UART':
		console.log(commOption + streamout(data));
		break;
	case 'TCPIP':
		const ipport = 57001;
		const data1 = [...alignValues( registers.ack, { value : ack++  & 0x7f } ), ...data ];
		var buffer  = new Uint8Array(data1.length+2);
	
		if (data1 instanceof Uint8Array) {
			for (i=0; i < data1.length; i++) {
				buffer[i] = data1[i];
			}
		} else {
			for (i=0; i < data1.length; i++) {
				buffer[i] = data1[i] & 0xff;
			}
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
		usbSend( 
			// [...alignValues( registers.ack, { value : ack++  | 0x80 } ),
			[...alignValues( registers.ack, { value : ack++  & 0x7f } ),
			 ...data ]);
		break;
	}
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

