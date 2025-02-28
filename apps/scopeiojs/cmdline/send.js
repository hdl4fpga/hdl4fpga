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

	let length = 0;
	while ((length+1) < data.length) {
		let step = ((data.charCodeAt(length+1) % 256) + 3);
		console.log("step", step);
		if ((length+step) <= data.length) {
			if (length+step <= (1024+8)) {
				length += step;
			} else if (length > 0) {
				commjs.send(data.slice(0, length));
				data = data.slice(length);
				length = 0;
			}
		} else break;
	}
	if (length > 0) {
		commjs.send(data.slice(0, length));
		data = data.slice(length);
	}
	if (data.length > 0) 
		console.log("length %d, data left %s", data.length, data);
});





