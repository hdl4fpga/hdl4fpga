// Copyright (c) <2015> <Miguel Angel Sagreras>                                    //
//                                                                                 //
// Permission is hereby granted, free of charge, to any person obtaining a copy of //
// this software and associated documentation files (the "Software"), to deal in   //
// the Software without restriction, including without limitation the rights to    //
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   //
// of the Software, and to permit persons to whom the Software is furnished to do  //
// so, subject to the following conditions:                                        //
//                                                                                 //
// The above copyright notice and this permission notice shall be included in all  //
// copies or substantial portions of the Software.                                 //
//                                                                                 //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    //
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        //
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     //
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          //
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   //
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   //
// SOFTWARE.                                                                       //
//                                                                                 //

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
