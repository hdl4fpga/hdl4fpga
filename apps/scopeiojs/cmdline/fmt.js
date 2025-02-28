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
	.requiredOption('-r, --rid  <id>',   'register id')
	.requiredOption('-d, --data <name>', 'data')
	.parse(process.argv);

function hex(data) {
	var values = [];
	for (i = 0; i < data.length; i++) {
		let val;

		if (i % 2 == 0) {
			values.push(16*parseInt("0x" +  data[i]));
		} else {
			values.push(values.pop() + parseInt("0x" +  data[i]));
		}

	}
	return String.fromCharCode.apply(this, values);
}

var hexbuf = hex(program.data);
process.stdout.write(
	String.fromCharCode(parseInt("0x" + program.rid)) +
	String.fromCharCode(parseInt(hexbuf.length-1)) +
	hexbuf);





