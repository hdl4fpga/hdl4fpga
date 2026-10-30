// Copyright (c) 2015 Miguel Angel Sagreras                                       //
//                                                                                //
// Permission is hereby granted, free of charge, to any person obtaining a copy   //
// of this software and associated documentation files (the "Software"), to deal  //
// in the Software without restriction, including without limitation the rights   //
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      //
// copies of the Software, and to permit persons to whom the Software is          //
// furnished to do so, subject to the following conditions:                       //
//                                                                                //
// The above copyright notice and this permission notice shall be included in all //
// copies or substantial portions of the Software.                                //
//                                                                                //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     //
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       //
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    //
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         //
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  //
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  //
// SOFTWARE.                                                                      //
//                                                                                //

const program = require('commander');
const commjs  = require('./comm.js');

program
	.requiredOption('-l, --link <type>', 'udp | serial')
	.requiredOption('-n, --name <name>', 'hostname | ip address | serial port')
	.parse(process.argv);

switch(program.link) {
case 'serial':
	commjs.setCommOption('UART');
	commjs.createUART({ path: program.name, baudRate: 115200 });
	break;
case 'udp':
case 'ip':
	commjs.setCommOption('TCPIP');
	commjs.setHost(program.name);
	break;
default:
	program.help();
	break;
}

const MAX_PACKET_SIZE = 1024 + 8;
let pending = Buffer.alloc(0);
let packet = [];
let packetLength = 0;

function sendPacket() {
	if (packetLength === 0) return;
	const data = Buffer.concat(packet, packetLength);
	packet = [];
	packetLength = 0;
	Promise.resolve(commjs.send(data)).catch((error) => {
		console.error('Send failed:', error.message || error);
		process.exitCode = 1;
	});
}

process.stdin.on('data', function(chunk) {
	pending = Buffer.concat([pending, chunk]);

	while (pending.length >= 2) {
		const registerLength = pending[1] + 3;
		if (pending.length < registerLength) break;

		if (packetLength > 0 && packetLength + registerLength > MAX_PACKET_SIZE)
			sendPacket();

		packet.push(pending.subarray(0, registerLength));
		packetLength += registerLength;
		pending = pending.subarray(registerLength);
	}

	if (packetLength >= MAX_PACKET_SIZE) sendPacket();
});

process.stdin.on('end', function() {
	if (pending.length !== 0) {
		console.error('Truncated register at end of input (%d bytes remain)', pending.length);
		process.exitCode = 1;
		return;
	}
	sendPacket();
});

process.stdin.on('error', function(error) {
	console.error('Failed to read stdin:', error.message || error);
	process.exitCode = 1;
});
