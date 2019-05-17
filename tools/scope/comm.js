// Asynchronous communication
//

const SerialPort = require('serialport')
const Readline   = require('@serialport/parser-readline'); 
const parser     = new Readline();

const baudRates  = [ 9600, 38400, 115200 ];

let uart;

function streamout (buffer) {

	function logwrite (buffer) {
		const buf = Buffer.alloc(1,buffer);
		console.log(buf);
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
	console.log(data);

	var e = document.getElementById("link-select");
	switch (parseInt(e.value)) {
	case 0:
		var buffer = Buffer.from(data);
		streamout(buffer);
		break;
	case 1:
		const ipport = 57001;
		h = document.getElementById("host");
		console.log(h.value);
		var buffer = Buffer.alloc(data.length+2);
		for (i=0; i < data.length; i++)
			buffer[i] = data[i];

		buffer[i++] = 0xff;
		buffer[i++] = 0xff;
		udpsckt.send(buffer, ipport, h.value, function(err, bytes) {
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
